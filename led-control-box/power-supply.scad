//
module power_supply() {
	l=143.0;
	d=59.0;
	h=40.0;
	il=11.0;
	wt=2.0;
	sd=3.175;

	difference() {
		cube([l,d,h],center=true);
		// 5V DC connections cutout
		translate([(l/2)-(il/2),wt/2,wt/2]) 
			cube([il+0.1,59-wt+0.1,h-wt+0.1],center=true);
		// screw hole on 5V DC side
		translate([(l/2)-(4.7625),-(d/2-wt-0.1),(h/2)-15.875]) 
			rotate([90,0,0]) 
				cylinder(d=sd,h=wt+0.2);

		// 120V AC connections cutout
		translate([-((l/2)-(il/2)),wt/2,wt/2]) 
			cube([il+0.1,59-wt+0.1,h-wt+0.1],center=true);
		// screw slot on 120V DC side
		translate([-((l/2)-(4.7625)),-(d/2-wt-0.1),(h/2)-15.875]) 
			rotate([90,0,0]) 
				cylinder(d=sd,h=wt+0.2);
	}
}

power_supply();

