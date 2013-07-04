VibrationPatterns
=================

iOS App to demonstrate use of creating patterns of vibration on devices which are vibration-capable (iPhone).

### !!! Warning !!!

The code demonstrates use of **private API** in iOS SDK so use at your own risk.


Screenshot
------------

![Screenshot of the App](http://www.noxymo.com/vibration/Screenshot.png "App Screenshot")


Code
-------------------------
### Vibrations & Intensity

The code allows to specify a certain amount of **vibration events** to be scheduled. This number of events is played with a certain **intensity** of the vibration hardware.

### Timing

You can use the sliders to configure the **duration** of a vibration event should last in milliseconds and how long the **pause** inbetween two events should be. 

### Configuration

In the `.pch-File` you can configure some flags for debugging. Please keep in mind that this stuff needs an iPhone (i.e. hardware with a vibration motor inside) to actually create some effect. On iPod & iPad this app will do nothing but playing a sound of silence.

Have fun!
----------------------------
If you like the app you may find a visit to my blog worthwhile over there at [Thetawelle](http://www.thetawelle.de "Thetawelle das Blog"). It has a lot of links to iOS Development related stuff.