import Adafruit_BBIO.ADC as ADC
import time

sensor_pin = 'P9_40'

ADC.setup()

fo = open("/tmp/temp", "w")

while True:
	reading = ADC.read(sensor_pin)
	millivolts = reading * 1800  # 1.8V reference = 1800 mV
	temp_c = ((millivolts - 500) / 10) + 3
	#temp_f = (temp_c * 9/5) + 32
	#print('mv=%d C=%f F=%d' % (millivolts, temp_c, temp_f))
	fo.truncate()
	fo.seek(0)
	fo.write("%f" % temp_c)
	time.sleep(0.5)
