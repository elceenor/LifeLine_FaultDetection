#!/usr/bin/env python3

## @file: lifeline_FDC.py
#  GUI to display the data collected from the lifeline. Also includes
#  functionality to log this data and detect mass imbalances. Uses PyQt5 to generate the GUI.
#
# @author: Ryan Zhan
# Sept 26, 2020

import serial
import datetime
import datawriter
import plotbox
import math

import numpy as np
import numpy.fft as fft

from PyQt5 import QtCore,QtGui
from PyQt5.QtWidgets import (QApplication, QMainWindow, QGridLayout,
        QTabWidget, QHBoxLayout, QWidget, QDoubleSpinBox, QPushButton,
        QGroupBox, QSpinBox, QVBoxLayout, QCheckBox, QLineEdit, 
        QLabel)

import NSET
import SPRT
import AFFT

## Serial address used by the lifeline
life_addr = "/dev/ttyUSB0"
baud_rate = 115200

## Object to hold the data_writer
data_writer = None

## Serial port that the Lifeline is connected to
life_port = None

## Array to hold the current set of x acceleration data for the current set
xaccels = [0]

## Array to hold the current set of y acceleration data for the current set
yaccels = [0]

## Array to hold the rms average of y acceleration using sets of ~5s of data
y_accel_ave = [0] 

## Array to hold the current set of z acceleration data for the current set
zaccels = [0]

## Array to hold the rotor speeds
rot_speeds = [0]

## Array to hold voltage values
volt_vals = [0]

## Array to hold current values
curr_vals = [0]

## Array to hold the index values
index_val = [0]

## The rate at which the plots should update (in milliseconds)
plot_rate = 500

# Initialize NSET+SPRT and AFFT
nrml = [300,300*5,4*1024,4*1024,18*1024,5E5,5E5,5E5]
NSET_obj = NSET.NSET('NSET_memory.txt','NSET_inverse.txt',6,nrml)
SPRT_obj = SPRT.SPRT()

AFFT_obj = AFFT.AFFT()
AFFT_obj.load('AFFT_threshold.txt')

fault_freqs=[]
log_freq = 50

window = None
#=================================Functions=====================================
def timer_says ():
    ''' Function called by the Qt timer whenever there's nothing else to be
    done (as in, important luser input). "Borrowed" from JR Ridgely's function
    from the previous turbine control software.'''

    global log_count
    global logging_string
    global fault_freqs

    line = ''
    if life_port.in_waiting:
        # check the lifeline for acceleration data
        b_line = (life_port.readline ())
        #decode the line and write the line to the data file
        try:
            
            decoded = b_line.decode()
            data_writer.writeData (decoded)
        except UnicodeDecodeError:
            line = '# Bad line: Unicode decode error.\n' 
        else:
            if decoded == '':
                # ignore empty strings
                line = None
            
            elif decoded[0]=='A':
                # text, just ignore it
                line = None

            elif decoded[0] == 'M':
                # start of dataset, write a time stamp to the data file
                time_val = datetime.datetime.now ().strftime('%H:%M:%S')
                line = '# Dataset recieved: '+time_val + '\n' + str(b_line) + '\n'
                
            elif decoded[0] == '$':
                # end of data set
                line = None               
           

            elif decoded[0] == '~':

                values = decoded.split(',')
                if len (values) == 8:

                    try:
                        #Try to convert the line into proccessable data
                        index_val.append(values[0])
                        # convert the values of accleration to units of g's
                        xaccels.append ((float)(values[1]))
                        yaccels.append ((float)(values[2]))
                        zaccels.append ((float)(values[3]))
                        # convert the rotor speed to floats
                        rot_speeds.append ((float)(values[4]))
                        curr_vals.append ((float)(values[5]))
                        volt_vals.append ((float)(values[6]))
                    except IndexError:
                        line = '# Bad Line: Index Error.\n'
                    except ValueError:
                        line = '# Bad Line: Value Error.\n'
                    else:

                        if (len(yaccels)%500 == 0):
                            #Extract last 500 datapoints
                            xaccels_short = xaccels[-500:]
                            yaccels_short = yaccels[-500:]
                            zaccels_short = zaccels[-500:]
                            rot_speeds_short = rot_speeds[-500:]
                            volts_short = [convert_volts(x) for x in volt_vals[-500:]]
                            amps_short = [convert_curr(x) for x in curr_vals[-500:]]

                            #Calculate the RMS value
                            x_RMS = math.sqrt( sum([x**2 for x in xaccels_short] )/500 )
                            y_RMS = math.sqrt( sum([y**2 for y in yaccels_short] )/500 )
                            z_RMS = math.sqrt( sum([z**2 for z in zaccels_short] )/500 )

                            #Calculate Line Length values
                            x_LL = sum( [ math.sqrt((x_i - x_j)**2 + (1/log_freq)**2) for x_i,x_j in zip(xaccels_short[1:],xaccels_short[0:-1])])
                            y_LL = sum( [ math.sqrt((y_i - y_j)**2 + (1/log_freq)**2) for y_i,y_j in zip(yaccels_short[1:],yaccels_short[0:-1])])
                            z_LL = sum( [ math.sqrt((z_i - z_j)**2 + (1/log_freq)**2) for z_i,z_j in zip(zaccels_short[1:],zaccels_short[0:-1])])
                            
                            #Calculate the average rotorspeed and power
                            rot_av = sum(rot_speeds_short)/len(rot_speeds_short)
                            pows = [x*y for x,y in zip(volts_short,amps_short)]
                            pow_av = sum(pows)/len(pows)

                            #Format observed data vector
                            X_obs_lrg = [rot_av,pow_av,x_RMS,y_RMS,z_RMS,x_LL,y_LL,z_LL]

                            if rot_av >=30:

                                resid = NSET_obj.calc_resid(X_obs_lrg)
                                fault = SPRT_obj.calc_index(resid)

                                if fault:
                                    NSET_obj.fault_flag = True
                                    NSET_obj.last_five.append(1)
                                else:
                                    NSET_obj.fault_flag = False
                                    NSET_obj.last_five.append(0)

                                NSET_obj.last_five.pop(0)

                            y_accel_ave.append(y_RMS)

                            window.UpdateAverage()
                            window.UpdateSPRT()
                            

                        if (len(yaccels)%1024 == 0):
                            yaccels_long = yaccels[-1024:]
                            rot_speeds_long = rot_speeds[-1024:]

                            rot_av = sum(rot_speeds_long)/len(rot_speeds_long)

                            if rot_av >= 30:
                                [fault_freqs] = AFFT_obj.examine(yaccels_long,rot_speeds_long)

                                if fault_freqs:
                                    AFFT_obj.fault_flag = True
                                    AFFT_obj.last_five.append(1)
                                else:
                                    AFFT_obj.fault_flag = False
                                    AFFT_obj.last_five.append(0)

                                AFFT_obj.last_five.pop(0)

                                AFFT_obj.has_tested = True

                            # update the average plot
                            window.UpdatePowerSpec()
                            log = True

                        if NSET_obj.has_tested and AFFT_obj.has_tested:
                        
                            if NSET_obj.fault_flag and AFFT_obj.fault_flag:
                                alarms += 1
                            
                            elif sum (NSET_obj.last_five) > 4:
                                alarms += 1

                            elif sum (AFFT_obj.last_five) > 4:
                                alarms += 1

                            NSET_obj.has_tested = False
                            AFFT_obj.has_tested = False
                        
                            if NSET_obj.fault_flag:
                                print('NSET logged a fault.')
                            if AFFT_obj.fault_flag:
                                print('AFFT logged faults.')
                                mass = any([(x>0.5 and x<1.5) for x in fault_freqs])
                                aero = any([(x>2.5 and x<3.5) for x in fault_freqs])
                                if mass and aero:
                                    print('     Mass and aerodynamic imbalance detected!')
                                elif mass:
                                    print('     Mass imbalance detected!')
                                elif aero:
                                    print('     Aerodynamic imbalance detected!')

                                if NSET_obj.fault_flag and AFFT_obj.fault_flag:
                                    print('Both NSET and AFFT logged faults.')

                                    if NSET_obj.fault_flag and AFFT_obj.fault_flag:
                                        alarms += 1
                                    
                                    elif sum (NSET_obj.last_five) > 4:
                                        alarms += 1

                                    elif sum (AFFT_obj.last_five) > 4:
                                        alarms += 1

                                    NSET_obj.has_tested = False
                                    AFFT_obj.has_tested = False

                                
                                elif curr_NSET_fault:
                                    print('NSET logged faults.')
                                
                                elif curr_AFFT_fault:
                                    print('AFFT logged faults.')
                                    mass = any([(x>0.5 and x<1.5) for x in fault_freqs])
                                    aero = any([(x>2.5 and x<3.5) for x in fault_freqs])
                                    if mass and aero:
                                        print('     Mass and aerodynamic imbalance detected!')
                                    elif mass:
                                        print('     Mass imbalance detected!')
                                    elif aero:
                                        print('     Aerodynamic imbalance detected!')

                        line = "{:s},{:f},{:f},{:f},{:f}\n".format (index_val[-1],
                            xaccels[-1],yaccels[-1],zaccels[-1],rot_speeds[-1])
                else:
                    line = "# Bad Line: Invalid data length.\n"
       
def update_gui ():
    ''' This function updates the accelerations plots. Called by the second 
    Qtimer with the purpose of lowering cpu load.
    '''
    
    window.UpdatePlots ()
    window.UpdateValues ()

def convert_curr (curr):
    ''' This function converts current data from the lifeline to its useful form.
    '''
    # Value of the voltage divider on the LifeShoe
    voltage_divider = 0.625
    # Current sensor sensitivity [V/Amp]
    curr_sens = 0.625/20
    # current adjustment
    k_cur = -0.79
    
    curr_conv = ((((((curr-21)/1239)/voltage_divider)-2.5)/curr_sens)+k_cur)
    
    return curr_conv

def convert_volts (volt):
    ''' This function converts voltage data from the lifeline to
    its useful form.
    '''
    # Value of the voltage divider on the LifeShoe
    voltage_divider = 0.625
    # Voltage sensor sensitivity [V/Amp]
    volt_sens = 25.5
    # Hi Power resistor value on the Power transducer
    resistor_value = 15100
    # voltage adjustment
    k_volt = -17.67

    volt_conv = (((((((((volt-21)/1236))/voltage_divider)-2.3)/volt_sens)*resistor_value)+k_volt))

    return volt_conv

def CalcPowerSpec (dataArray,dataPeriod):
    """ This function removes a fixed bias from the data
    and calculates the power spectrum and frequency range of the dataset.
    @param dataArray The array of data points to calculate the power spectrum from
    @param dataPeriod The time, in seconds, between each data point
    @return a list containing the power spectrum and the corresponding frequencies 
    """
    mean = sum(dataArray)/len(dataArray)
    correctedArray = [x-mean for x in dataArray]
    ps = np.abs((fft.fft(correctedArray)))**2
    freq = fft.fftfreq(len(correctedArray),d=dataPeriod)
    return [ps,freq]

#===================================Classes=====================================
        
# Subclass QMainWindow to customize the application's main window
class MainWindow (QMainWindow):
    '''This is a subclass of the PyQt5 QMainWindow object. Within will
    be several custom functions to generate the UI for the turbine 
    controller. It also contains the functions to handle button clicks.
    '''
    def __init__(self, *args, **kwargs):
        super (MainWindow, self).__init__(*args, **kwargs)
        self.setWindowTitle("Wind Turbine Controller")

        # Generate the different sections of the GUI
        self.CreateLoggingBox ()
        self.CreateValDisplay ()
        self.CreatePlots ()
        self.CreatePlotOptions ()

        # Create the main layout
        mainLayout = QGridLayout ()

        # Fill the layout
        mainLayout.addWidget (self.loggingGroupBox, 2, 2)
        mainLayout.addWidget (self.valDisplayGroup, 2, 0)
        mainLayout.addWidget (self.plotGroup, 0, 0, 1, 3)
        mainLayout.addWidget (self.plotOptionsGroup,2,1)
       
        # Create the main widget
        mainWidget = QWidget ()

        # Fill the widget with the main layout
        mainWidget.setLayout (mainLayout)
        self.setCentralWidget (mainWidget)

        # Set the size of the window
        self.setFixedSize (940,790)

#-------------------------------------------------------------------------------    
    def CreatePlots (self):
        '''This function creates the plots using the plotbox library by JR.
        It also fits the plots into the overall GUI.
        '''

        # create PDPlotBox(es) and add it to the GUI
        self.x_accel_box = plotbox.PlotBox (title='X Accel', xlabel='Index',
                                            ylabel='Acceleration [g\'s]',
                                            over_view=False, scroll_points=300)
        
        self.x_accel_box.show_grid (False, True, 0.5)
        self.x_accel_box.set_up_rt (1, ['X acceleration'])


        self.y_accel_box = plotbox.PlotBox (title='Y Accel', xlabel='Index',
                                            ylabel='Acceleration [g\'s]',
                                            over_view=False, scroll_points=300)
       
        self.y_accel_box.show_grid (False, True, 0.5)
        self.y_accel_box.set_up_rt (1, ['Y acceleration'])


        self.z_accel_box = plotbox.PlotBox (title='Z Accel', xlabel='Index',
                                            ylabel='Acceleration [g\'s]',
                                            over_view=False, scroll_points=300)
       
        self.z_accel_box.show_grid (False, True, 0.5)
        self.z_accel_box.set_up_rt (1, ['Z acceleration'])

        # plot for the average
        self.average_box = plotbox.PlotBox (title='RMS Average', xlabel='Index',
                                            ylabel='Acceleration [g\'s]',
                                            over_view=False, scroll_points=60)
        
        self.average_box.show_grid (False, True, 0.5)
        self.average_box.full_plot ([],[])
        
        self.average_box.set_up_rt (1, ['RMS acceleration'])


        # plot for the average
        self.power_box = plotbox.PlotBox (title='Power Spectrum', xlabel='Freq [hz]',
                                            ylabel='Acceleration [g]',
                                            over_view=False)
        self.power_box.set_y_range(0, 2000.0)
        self.power_box._plot.setXRange(0,10)
        self.power_box.autoscale_on
        self.power_box.show_grid (False, True, 0.5)
        self.power_box.full_plot ([],[[],[]],curve_names=['FFT','Imbalance Threshold'])



        # Plot for the SPRT indices
        self.SPRT_ind_box = plotbox.PlotBox (title='SPRT Indices', xlabel='Index',
                                            ylabel='SPRT Index',
                                            over_view=False, scroll_points=60)
        # self.SPRT_ind_box.set_y_range()
        self.SPRT_ind_box.full_plot ([],[])

        self.SPRT_ind_box.set_up_rt (1, ['SPRT index'])

        # Create group box for the plots
        self.plotGroup = QGroupBox ()
        
        self.plotGroup.setFixedSize (922,584)
        # Create plotbox layout
        plotlayout = QVBoxLayout ()
        
        # Add plots to layout
        plotlayout.addWidget (self.x_accel_box)
        plotlayout.addWidget (self.y_accel_box)
        plotlayout.addWidget (self.z_accel_box)
        plotlayout.addWidget (self.average_box)
        plotlayout.addWidget (self.power_box)
        plotlayout.addWidget (self.SPRT_ind_box)
        self.plotGroup.setLayout (plotlayout)

    def UpdatePowerSpec (self):
        freqs = list(AFFT_obj.lastFreq[0:511])
        spects = list(AFFT_obj.lastSpect[0:511])
        thrs = list(AFFT_obj.thr[0:511])

        self.power_box.full_plot (freqs,[spects,thrs],curve_names=['FFT',
                'Imbalance Threshold'])
        
    def UpdateAverage (self):
        ''' Updates the RMS average plot.
        '''
        self.average_box.put_data (len(y_accel_ave),[y_accel_ave[-1]])

    def UpdateSPRT (self):
        ''' Updates the SPRT result plot.
        '''
        self.SPRT_ind_box.put_data (len(y_accel_ave),[SPRT_obj.SPRT_ind[1]])

    def UpdatePlots (self):
        '''Update the data in the plots.
        '''
      
        # put the data into the plotbox(es)
        self.y_accel_box.put_data (len(yaccels), [yaccels[-1]])
        self.x_accel_box.put_data (len(xaccels), [xaccels[-1]])
        self.z_accel_box.put_data (len(zaccels), [zaccels[-1]])

    def ClearPlots (self):
        ''' Reset the plots so that they can start graphing the next set of life
        line data.
        '''
        self.x_accel_box.set_up_rt (1, ['X acceleration'])
        self.y_accel_box.set_up_rt (1, ['Y acceleration'])
        self.z_accel_box.set_up_rt (1, ['Z acceleration'])

#-------------------------------------------------------------------------------
    def CreatePlotOptions (self):
        '''Create options to toggle different plots.
        '''
        self.plotOptionsGroup = QGroupBox("Plot Options")

        # create items to fill the plot options
        self.xAccelCheck = QCheckBox("X Acceleration")
        self.yAccelCheck = QCheckBox("Y Acceleration")
        self.zAccelCheck = QCheckBox("Z Acceleration")
        self.RMSCheck = QCheckBox ("RMS Average")
        self.powerCheck = QCheckBox("Power Spec")
        self.SPRTCheck = QCheckBox("SPRT Indices")

        self.xAccelCheck.setChecked (False)
        self.yAccelCheck.setChecked (True)
        self.zAccelCheck.setChecked (False)
        self.RMSCheck.setChecked (False)
        self.powerCheck.setChecked (True)
        self.SPRTCheck.setChecked (False)

        # Link the checkboxes to functions
        self.xAccelCheck.toggled.connect (self.xAccelCheckFun)
        self.yAccelCheck.toggled.connect (self.yAccelCheckFun)
        self.zAccelCheck.toggled.connect (self.zAccelCheckFun)
        self.RMSCheck.toggled.connect (self.RMSCheckFun)
        self.powerCheck.toggled.connect (self.powerCheckFun)
        self.SPRTCheck.toggled.connect (self.SPRTCheckFun)

        # Choose layout for the plot box
        plotOptionsLayout = QVBoxLayout()

        plotOptionsLayout.addWidget(self.xAccelCheck)
        plotOptionsLayout.addWidget(self.yAccelCheck)
        plotOptionsLayout.addWidget(self.zAccelCheck)
        plotOptionsLayout.addWidget(self.RMSCheck)
        plotOptionsLayout.addWidget(self.powerCheck)

        # Add the layout to the plot options group
        self.plotOptionsGroup.setLayout(plotOptionsLayout)
    
    def xAccelCheckFun (self):
        ''' Hides or shows the x acceleration plot box depending on its previous
        state.
        '''
        self.x_accel_box.setHidden (not self.xAccelCheck.isChecked ())

    def yAccelCheckFun (self):
        ''' Hides or shows the y acceleration plot box depending on its previous
        state.
        '''
        self.y_accel_box.setHidden (not self.yAccelCheck.isChecked ())
    def zAccelCheckFun (self):
        ''' Hides or shows the z acceleration plot box depending on its previous
        state.
        '''
        self.z_accel_box.setHidden (not self.zAccelCheck.isChecked ())
    def RMSCheckFun (self):
        ''' Hides or shows the RMS acceleration plot box depending on its previous
        state.
        '''
        self.average_box.setHidden (not self.RMSCheck.isChecked ())
    def powerCheckFun (self):
        ''' Hides or shows the power spectrum plot box depending on its previous
        state.
        '''
        self.power_box.setHidden (not self.powerCheck.isChecked ())
    def SPRTCheckFun (self):
        self.SPRT_ind_box.setHidden (not self.SPRTCheck.isChecked ())

#-------------------------------------------------------------------------------
    def CreateValDisplay (self):
        ''' Generate the various boxes that show the current
        wind speed, rotor speed, generator current, and generator
        voltage as reported by the Life Line.
        '''
        # Create groupbox for organization
        self.valDisplayGroup = QGroupBox("Important Values")

        

        self.rotorSpeedBox = QLineEdit ()
        self.rotorSpeedBox.setReadOnly (True)
        rotorGroup = QVBoxLayout ()
        rotorLabel = QLabel ("Rotor Speed [units]")
        rotorGroup.addWidget (rotorLabel)
        rotorGroup.addWidget (self.rotorSpeedBox)

        self.currentBox = QLineEdit ()
        self.currentBox.setReadOnly (True)
        currentGroup = QVBoxLayout ()
        currentLabel = QLabel ("Gen. Current [A]")
        currentGroup.addWidget (currentLabel)
        currentGroup.addWidget (self.currentBox)

        self.voltageBox = QLineEdit ()
        self.voltageBox.setReadOnly (True)
        voltageGroup = QVBoxLayout ()
        voltageLabel = QLabel ("Gen. Voltage [V]")
        voltageGroup.addWidget (voltageLabel)
        voltageGroup.addWidget (self.voltageBox)

        # Set the layout of the groupbox
        valDisplayLayout = QHBoxLayout ()
        valDisplayLayout.addLayout (rotorGroup)
        valDisplayLayout.addLayout (currentGroup)
        valDisplayLayout.addLayout (voltageGroup)
        self.valDisplayGroup.setLayout (valDisplayLayout)
    
    def UpdateValues (self):
        '''Update the values within the ValDisplay section. These values include
        rotor speed, generator current, and generator voltage.
        '''
        # Value of the voltage divider on the LifeShoe
        voltage_divider = 0.625
        # Current sensor sensitivity [V/Amp]
        curr_sens = 0.625/20
        # Voltage sensor sensitivity [V/Amp]
        volt_sens = 25.5
        # Hi Power resistor value on the Power transducer
        resistor_value = 15100
        # voltage adjustment
        k_volt = -17.67
        # current adjustment
        k_cur = -0.79

        self.rotorSpeedBox.setText (str(rot_speeds[-1]))
        self.voltageBox.setText ("{:.2f}".format((((((((volt_vals[-1]-21)/1236))
                /voltage_divider)-2.3)/volt_sens)*resistor_value)+k_volt))
                #-2.3)*resistor_value/volt_sens))
        self.currentBox.setText ("{:.2f}".format((((((curr_vals[-1]-21)/1239)
                /voltage_divider)-2.5)/curr_sens)+k_cur))

#-------------------------------------------------------------------------------
    def CreateLoggingBox (self):
        '''Generate the logging section of the GUI. It will include
        a SpinBox with another button to set the logging speed and 
        start/stop the logger respectively.
        '''
    
        # Create groupbox to hold everything
        self.loggingGroupBox = QGroupBox('Logging')

        # Create items to fill the grouppox
        self.logStartStopButton = QPushButton("Start")
        self.logStartStopButton.clicked.connect(self.LoggingClick)

        # Create layout
        loggingLayout = QVBoxLayout()
        loggingLayout.addWidget(self.logStartStopButton)

        self.loggingGroupBox.setLayout(loggingLayout)
    
    def LoggingClick (self):
        '''This function runs whenever the start/stop button is clicked.
        Toggles the data writer as well as changes the name of the button
        depending on what stated the data writer is in.
        '''
        
        global logging_string
        global log_freq
        
        data_writer.startStop ()
        if  data_writer.isWriting ():
            
            self.logStartStopButton.setText("Stop")
            
            
        else:
            log_bool = False
            self.logStartStopButton.setText("Start")
            
            
        

# ================================== Main ======================================

with serial.Serial (life_addr, baud_rate, timeout = 0.2) as life_port:

    # clear serial line
    life_port.flushInput ()

    data_writer = datawriter.DataWriter ("LifeLine")

    ## The instance of QApplication
    app = QApplication([])

    # create a window so we can actually see something
    window = MainWindow()
    
    window.show()

    # Start a timer to run the useful stuff. A timeout of zero means we will
    # make this an idle task that runs whenever nothing else needs to run
    t = QtCore.QTimer ()
    t.timeout.connect (timer_says)
    t.start (0)

    # Make a second timer specifically for updating the GUI's 
    t2 = QtCore.QTimer ()
    t2.timeout.connect (update_gui)
    t2.start (plot_rate)

    # Start the event loop
    app.exec_()