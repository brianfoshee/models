use <iec320.scad>
$fa=0.5;
$fs=0.5;
// Inner cube dimensions
l=228.6;
h=101.6;
d=72.6;
// wall thickness
wt=4.0;
// corner radius
cr=8.0;
// lid height
lh=16;

// Lid
*translate([0,0,60]) difference() {
	union() {
		for(x=[-1,1]) {
			for(y=[-1,1]) {
				translate([x*((l/2)),y*((d/2)),0]) 
					cylinder(r=cr,h=lh, center=true);
			}
		}
		cube([l,d+2*cr,lh], center=true);
		cube([l+2*cr,d,lh], center=true);
		// inner cube
		translate([0,0,-wt/2]) cube([l,d,lh+wt],center=true);
	}
	// inner-inner cube
	translate([0,0,-wt-0.1]) 
		cube([l-wt*2,d-wt*2,lh],center=true);
	for(i=[-10:1:10]) {
		// make a cube
	}
}

// main structure
difference() {
	translate([0,0,-((wt/2)+0.1)]) union() {
		for(x=[-1,1]) {
			for(y=[-1,1]) {
				translate([x*((l/2)),y*((d/2)),0]) 
					cylinder(r=cr,h=h+wt-0.1, center=true);
			}
		}
		cube([l,d+2*cr,h+wt-0.1], center=true);
		cube([l+2*cr,d,h+wt-0.1], center=true);
	}

	// inner cube
	cube([l,d,h],center=true);

	// IEC mounting screws
	translate([-(l/2)-wt,0,20]) {
		rotate([0,90,0]) {
			// top
			cylinder(h=wt*2+0.2,d=4.5,center=true);
			// bottom
			translate([40,0,0]) 
				cylinder(h=wt*2+0.2,d=4.5,center=true);
		}
	}

	// IEC320-C14 socket and rocker switch
	translate([-((l/2)+(2.4/2)+(wt*2)+0.1),0,0])
		rotate([0,0,90])
			iec320_socket();

	// Power Supply mounting screws
	// AC
	translate([-(d/2)-30.4,-(d/2)-wt,-((h/2)-15-9)]) 
		rotate([90,0,0])
			cylinder(h=wt*2+0.2,d=3.175,center=true);
	// DC
	translate([(d/2)+30.4,-(d/2)-wt,-((h/2)-15-9)]) 
		rotate([90,0,0])
			cylinder(h=wt*2+0.2,d=3.175,center=true);
}

// IEC320-C14 socket and rocker switch
%translate([-((l/2)+(2.4/2)+(wt*2)+0.1),0,0])
	rotate([0,0,90])
		iec320_socket();

// 5V power supply
use <power-supply.scad>
%translate([0,-(d/2)+(59/2),-((h/2)-(40/2))]) 
	power_supply();