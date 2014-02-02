# What's in a Spec?

What are the basic elements of behaviour that might determine
the correctness or otherwise of a given device?

Here are some odd thoughts so far...

## Basic Terms

* a set of **wires**, just symbolic names

* a set of **connections**
  * from the stimulator to the device-under-test, relating the
    symbolic name to pin nubers at ether end
  * from the device-under-test to the observer, relating the
    symbolic name to device pin numbers and observer channels

* a set of **events**, including
  * **positive-edge** - change from 0 to 1 on a given wire
  * **negative-edge**  - change from 1 to 0 on a given wire
  * **any-edge** - either of the above
  * **glitch** - two edges on a gven wire within a given 
    time threshold

## Higher-level Terms

### Response times

A _response_ event should occur within a given time from a _stimulus_
event, e.g. a motor must be stopped when a limit-switch is activated.

### Poll intervals

An event should always occur within a maximum time from the previous
occurrence of that same event, e.g. resetting a watchdog circuit, or
polling a sensor for input.

### Setup-and-Hold times

Writing data to a peripheral device generally follows the same
sequence:

  1. The data value is output on a wire (or parallel set of wires)
     which I shall call the data bus.
  2. The signal level on the data bus may take some time to settle
     due to 'real-world' factors like inductance or capacitance that
     we software folk prefer to ignore
  3. Another wire (which I shall call the strobe) is set to indicate
     to the peripheral device that the data is to be read.
  4. The device will take a certain amount of time to leap into action
     and actually read the data. During this time, the signal levels
     on the data bus must be held steady
  5. Ok, the deed is now done, the strobe signal will be
     reset and the data bus is free to be set up for the next
     activity.

  So, in testing terms, we can identify the following parameters:
  
  * the _strobe_ wire
  * the _data bus_ wire(s)
  * The positive- (or negative-) _edge_ on the strobe line gives us a
    time reference for the whole procedure
  * The _setup time_ before the strobe, during which the bus must not
    change
  * The _hold time_ after the strobe, during which the bus must not
    change
  * The _strobe width_, the time between steps 3 and 5 above.
  * there is also, perhaps, a minimum interval before the next such
    cycle may occur. Is there a technical term for this?
    _recovery_ time perhaps?

## Overall Settings for a measurement

* the basic timescale (xscope has a range from 500ns up to seconds.)
* the duration: is it a one-shot capture of an interaction or a
  longer-running 'monitoring'-type situation. Note xscope can only
  give you 256 time units in a one-shot measurements. If you need a
  longer capture window, you must run the xscope in 'auto' mode and
  search the data stream yourself to find the trigger point.
