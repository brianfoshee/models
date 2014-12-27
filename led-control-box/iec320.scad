// Module definition of an IEC320 C14 Socket with Rocker Switch.
module iec320_socket() {
	// Frame dimensions
	flength=58.3; // x
	fwidth=2.4;   // Y (depth)
	fheight=58.3; // Z
	// Electronics dimensions
	elength=46.8; // X
	elength2=6.35;// X1
	ewidth=16.5;  // Y (depth)
	eheight=27.0; // Z
	eheight2=14.2875; // Z2
	// other vars
	offset1 = elength2/2.0; // translate electronics block 1 this much
	offset2 = (elength/2.0) - offset1;
	

	// Mounting screw hole dimensions
	sdiam=4.5; // screw hole diameter
	shoffset=20.0; // screw hole offset from center

	union() {
	// Frame
	difference() {
		cube([flength,fwidth,fheight],center=true);
			// Two mounting holes
			for(y=[shoffset,-shoffset]) {
				translate([0,(fwidth/2)+0.1,y]) 
					rotate([90,0,0]) 
						cylinder(h=fwidth+0.2,d=sdiam);
			}
		}
		
		// Electronics
		translate([0,(-ewidth/2.0)-(fwidth/2.0),0]) {
			hull() {
				// Main cube
				translate([offset1,0,0]) 
					cube([elength-elength2,ewidth,eheight],center=true);
				// narrowing end
				translate([-offset2,0,0])
					cube([elength2,ewidth,eheight2],center=true);
				}
		}	
	}

}

iec320_socket();