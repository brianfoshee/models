// #cube() for debugging - makes it transparent
// *cube() ignores the object (both in viewing and final render)
// !cube() only shows that object and nothing else
// % Shows the object as half transparent (like #) and also does not render
// it in the final rendering.

$fa=1.5; // min angle between two facets
$fs=0.1; // min size of a facet (subdivide when a facet becomes too large)

use <TextGenerator.scad>;

scale([2,2,2]) {
	difference() {
		rotate([90,0,0]) import("bottom.stl");
		
		rotate([90,0,270]) {
			scale([3,3,7]) {
				translate([3.2,3,-0.8]) {
					union() {
						color([0.3,0.2,1]) drawtext("H");
						//translate([6,1,0]) color([1,0,1]) cube([5,5,1]);
						color([0.3,0.2,1]) 
						linear_extrude(1) 
						translate([8.5,3.5,0]) 
						scale([3,3.5,1]) circle(d=2);
					}
				}
			}
		}
	
		rotate([90,0,90]) {
			scale([3,3,7]) {
				translate([-14.8,3,7]) {
					union() {
						color([0.3,0.2,1]) drawtext("H");
						//translate([6,1,0]) color([1,0,1]) cube([5,5,1]);
						color([0.3,0.2,1]) 
						linear_extrude(1) 
						translate([8.5,3.5,0]) 
						scale([3,3.5,1]) circle(d=2);
					}
				}
			}
		}
	
		rotate([90,0,0]) {
			scale([3,3,7]) {
				translate([3.2,3,6.8]) {
					union() {
						color([0.3,0.2,1]) drawtext("H");
						//translate([6,1,0]) color([1,0,1]) cube([5,5,1]);
						color([0.3,0.2,1]) 
						linear_extrude(1) 
						translate([8.5,3.5,0]) 
						scale([3,3.5,1]) circle(d=2);
					}
				}
			}
		}
	}

}




	/*union() {
		rotate([90,0,270]) {
			translate([7.8,7,-5]) {
				scale([3,3,6]) color([0.3,0.2,1]) drawtext("HO");
			}
		}

		translate([-2,-46.5,10]) {
			color([1,0,1]) cube([8,18,18.5]);
		}
	}*/



//width=40;
//height=60;
//bottom_thickness=2;
//wall_thickness=5;
//
//difference()
//{
//	intersectionTe()
//	{
//		cube([width,width,height],center=true);
//		scale([1,1,height/width])
//			sphere(width/2 * sqrt(2));
//	}
//	translate([0,0,(-height/2)+bottom_thickness])
//		cylinder(r=width/2-wall_thickness,h=height);
//}

//difference()
//{
//	cube([20,20,20],center=true);
//
//	rotate([0,90.0])
//	{
//			translate([10,9.5,0])
//				cylinder(r=5,h=21,center=true);
//	}
//}
