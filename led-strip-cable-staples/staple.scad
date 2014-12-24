inl = 11; // Inner cutout length
inw = 6;  // Inner cutout width
inh = 1;  // Inner cutout height
scd = 1.041; // Screw diameter (19 gauge)
ol  = 22;    // Outer cube length
ow  = inw;   // Outer cube width
oh  = 3;     // Outer cube height
wl = (ol-inl)/2.0; // Wing width (nails go through the wings)

$fs = 0.1;
$fa = 1.5;

difference() {
	// Outer cube to cut from
	cube([ol,ow,oh]);

	// Inner cutout (for LED strip)
	translate([5.5,-0.1,-0.1]) cube([inl,inw+0.2,inh+0.1]);

	// Counter-sunk screw hole #1 (closest to origin)
	union() {
		translate([(wl/2),(ow/2),-0.1]) {
			cylinder(h=oh,r=scd);
			translate([0,0,oh-0.8]) cylinder(h=1,r=scd*1.5);
		}
	}
	
	// Counter-sunk screw hole #2
	union() {
		translate([ol-(wl/2),(ow/2),-0.1]) {
			cylinder(h=oh,r=scd); 
			translate([0,0,oh-0.8]) cylinder(h=1,r=scd*1.5);
		}
	}
}