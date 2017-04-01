import sys
import serial

def speech2num(a):
    com2num = {'Bulb':1,'Tubelight':2,'Fan':3,'Television':4,'Air':5,'Projector':6,'Laptop':7,'Cellphone':8}
    return com2num[a]

if __name__ == '__main__':
	x = sys.argv[1]
	sys.stdout.write(x)
	sys.stdout.write(str(speech2num(x)))
	#num = str(speech2num(x))
	ser = serial.Serial('COM15',9600,timeout=0)
	#ser.flush()
	while 1:
		#ser.flush()
   		ser.write(str(speech2num(x)))
   		if ser.read():
   			#ser.flush()
   			ser.close()
   			break