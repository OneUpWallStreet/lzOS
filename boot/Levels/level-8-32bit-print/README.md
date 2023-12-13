We cannot use BIOS interrupts to print values to the screen. Previously, we used int `0x10` to display values on the screen with the assistance of the BIOS, but that approach is no longer viable.

Instead, we need to utilize VGA memory; this will allow us to print to the top left of the screen.