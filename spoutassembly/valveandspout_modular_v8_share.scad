//------------------
// Generate STL file for multi-tastant spout
//------------------
// Nathan V-C
// 6/2015-10/2015
//------------------

// total height of support from floor of cage
supp_ht=33; 
// total width of support side to side
supp_w=35;
// width at top of support
supp_w_top=10;  // top is actually wider
// length of the spout support portion of the support
supp_ln=60;  
// distance base should extend forward of front edge of spout support
bs_ext=10;

// clearance value -- difference in size for pieces that need to fit in/around each other
cl=1;

// valve dimensions
r_mn=10.25; // radius of solenoid valves
r_big=13; // radius for the large pinch valve
r_tb=5;  // radius of holes for tubes in the valve holder
d_vb=9.2;  // distance to center of tube from flat edge of valve
d_vh=18; // depth of valve holder
th_v=1.5; // thickness for valve holder (for the version with the fluid tray) -- thinner than some other portions (in v6 was the same)

//distance bottom of valves should be from floor of cage -- actually end up thickness higher
v_ht=35; // higher to avoid some tubes running "down" and some running "up" 

thickness=2.5;  // wall thickness throughout assembly
dist_bt=40; // distance between valve support and spout support

// measurements for spout tubing brace attachment
barb_w=10; // width of barb connector
barb_ht=8.4; // height of barb connector
barb_th=3.5; // thickness of barb connector
barb_dpth=1.5;  // depth of groove to hold barb attachments in place
sp_diam=3; // diameter of hole to leave for spout itself (overestimate)

// measurements for nose cone
cn_diam_i=38.5; // inner dimension of nose cone (wall builds around this)
cn_diam_r=6; // inner diameter for opening at back of cone;
cn_depth=19; // depth of cone
led_diam=6; // diameter of hole to leave for LED lights
led_dpth=6.5; // depth of cylinder that LED fits into
led_wall=1;	  // width of wall that holds LED	
led_dist=5.5; // distance of LED hole from edge (dist to center)
br_sq=45.5; // dimension for square part of nose cone
center_ht=45;   // height of center of nose cone from floor, greater than supp_ht
l_cn_br=20; // length of cone brace, distance that flange extends beyond rear of cone to hook onto the tubing brace

// calculations for removing material from spout base
h_sz=(supp_ln-4*thickness)/3;
supp_diag=-0.5*sqrt(2*pow(thickness/2,2));
cube_side=2*min(v_ht,supp_w)/5;
cube_diag=0.5*sqrt(2*pow(cube_side,2));
min_dim=min(v_ht,supp_w);

// dimensions for PCB & battery tray
th_sp=2.5; // thickness of walls in the spout attaching to
th=1.5; // thickness of walls in the pcb tray
pcb_l=90.5; // length of pcb tray
pcb_w=40.5; // width of pcb tray
batt_l=55.5; // dimension for 9V holder
batt_w=31;    // dimensions for 9V holder
batt_th=17;
d_flr=5; // distance of bracket from floor
d_spt=5; // distance of pcb from spout base
gv_dpth=2.5;
batt_o=22.5;
batt_e=8; // amount that holder lip overlaps battery
co=25; // how wide to make cutout for ground wires

//**********
//**********
//------------
// modular part generation -- comment in/out to generate parts that you need
//------------

spout_base(0,0,0);
valve_stand_orig(0,-50,0);
tubing_brace(-(supp_ln+l_cn_br+20),0,0);
spout_shield(-(supp_ln+l_cn_br+20),50,0,1,.5);
nose_cone(-50,-50,0);
cage_bracket(-120,-50,0);

lock_hole_pin(-20,35,0);
lock_hole_pin(-30,35,0);
lock_hole_pin(-40,35,0);
lock_hole_pin(-50,35,0);

// items specific to nathan's set-up
// pcb_tray(0,v_ht+30,0);
// valve_stand_fluidcont(0,-50,0);

//***********
//***********

//---------------------
// Spout base
//----------------------

module spout_base(xp,yp,zp){

translate([xp,yp,zp])

	union(){
		union(){
			difference(){
				union(){
					// spout support
					translate([dist_bt+2*thickness+2*r_mn,0,0])cube([supp_ln,supp_ht,supp_w]);
					//base
					cube([supp_ln+bs_ext+dist_bt+2*thickness+2*r_mn,thickness,supp_w]);
					//valve support
					cube([r_mn*2+2*thickness,v_ht,supp_w]);
					// small circles to help hold valve holder onto support
					translate([thickness+r_mn,v_ht+0.75*thickness,supp_w/2-r_mn-thickness/2])rotate(90,[1,0,0])cylinder(h=thickness, r=r_mn/2-.5,center=false);
					translate([thickness+r_mn,v_ht+0.75*thickness,supp_w/2+r_mn+thickness/2])rotate(90,[1,0,0])cylinder(h=thickness, r=r_mn/2-.5,center=false);
					//extra support for seams
					translate([2*r_mn+2*thickness,supp_diag+thickness/2,0])rotate(45,[0,0,1])cube([thickness,thickness,supp_w]);	
					translate([2*r_mn+2*thickness+dist_bt,supp_diag+thickness/2,0])rotate(45,[0,0,1])cube([thickness,thickness,supp_w]);	
					translate([2*r_mn+2*thickness+dist_bt+supp_ln,supp_diag+thickness/2,0])rotate(45,[0,0,1])cube([thickness,thickness,supp_w]);	
				}
				union(){
					// slant at top of spout support
					translate([-thickness,supp_ht,-0.5*sqrt(2*pow((supp_ht-supp_w_top)/2,2))])rotate(45,[1,0,0])
					translate([dist_bt+2*thickness+2*r_mn,0,0])cube([supp_ln+2*thickness,(supp_ht-supp_w_top)/2,(supp_ht-supp_w_top)/2]);
			
					translate([-thickness,supp_ht,-0.5*sqrt(2*pow((supp_ht-supp_w_top)/2,2))+supp_w])rotate(45,[1,0,0])
					translate([dist_bt+2*thickness+2*r_mn,0,0])cube([supp_ln+2*thickness,(supp_ht-supp_w_top)/2,(supp_ht-supp_w_top)/2]);
			
					// remove squares from spout support to reduce volume
					translate([supp_ln-thickness-h_sz+dist_bt+2*thickness+2*r_mn,thickness,-thickness])cube([h_sz,supp_ht-2*thickness,supp_w+2*thickness]);
					translate([supp_ln-2*thickness-2*h_sz+dist_bt+2*thickness+2*r_mn,thickness,-thickness])cube([h_sz,supp_ht-2*thickness,supp_w+2*thickness]);
					translate([supp_ln-3*thickness-3*h_sz+dist_bt+2*thickness+2*r_mn,thickness,-thickness])cube([h_sz,supp_ht-2*thickness,supp_w+2*thickness]);
			
					// remove square from valve support
					translate([thickness,thickness,-thickness])cube([2*r_mn,v_ht-2*thickness,supp_w+2*thickness]);
			
					// remove material from valve support base in the x direction, use circles to keep printability in z direction
					translate([-thickness,v_ht/2,supp_w/2])rotate(90,[0,1,0])cylinder(h=4*thickness+2*r_mn, r=min_dim/2-2*thickness);
			
					// remove material from spout support base in the x direction, use circle to keep printability in z direction
					translate([dist_bt+thickness+2*r_mn,supp_ht/2+2.5,supp_w/2])rotate(90,[0,1,0])cylinder(h=2*thickness+supp_ln, r=(supp_ht-supp_w_top-thickness)/2-2*thickness);
			
					// remove locking holes
					union(){
						translate([0.25*supp_ln+dist_bt+2*thickness+2*r_mn,supp_ht-thickness,supp_w/2])rotate(-90,[1,0,0])lock_hole_btm(0,0,0);
						translate([0.75*supp_ln+dist_bt+2*thickness+2*r_mn,supp_ht-thickness,supp_w/2])rotate(-90,[1,0,0])lock_hole_btm(0,0,0);
					}
				}
			}
		}

		// add  back some more extra support for seams
		union(){
			//extra support for seams	
			translate([2*r_mn+2*thickness+dist_bt+thickness,supp_diag+thickness/2,0])rotate(45,[0,0,1])cube([thickness,thickness,supp_w]);	
			translate([2*r_mn+2*thickness+dist_bt+thickness+h_sz,supp_diag+thickness/2,0])rotate(45,[0,0,1])cube([thickness,thickness,supp_w]);	
			translate([2*r_mn+2*thickness+dist_bt+2*thickness+h_sz,supp_diag+thickness/2,0])rotate(45,[0,0,1])cube([thickness,thickness,supp_w]);	
			translate([2*r_mn+2*thickness+dist_bt+2*thickness+2*h_sz,supp_diag+thickness/2,0])rotate(45,[0,0,1])cube([thickness,thickness,supp_w]);	
			translate([2*r_mn+2*thickness+dist_bt+3*thickness+2*h_sz,supp_diag+thickness/2,0])rotate(45,[0,0,1])cube([thickness,thickness,supp_w]);	
			translate([2*r_mn+2*thickness+dist_bt+3*thickness+3*h_sz,supp_diag+thickness/2,0])rotate(45,[0,0,1])cube([thickness,thickness,supp_w]);	
			translate([thickness,supp_diag+thickness/2,0])rotate(45,[0,0,1])cube([thickness,thickness,supp_w]);	
			translate([thickness+2*r_mn,supp_diag+thickness/2,0])rotate(45,[0,0,1])cube([thickness,thickness,supp_w]);	
		}
	}
}

//-----------------------
// separate stand for valves, include one slot for large pinch valve
//----------------------

module valve_stand_large(xp,yp,zp){

translate([xp,yp,zp])

	union(){
		difference(){
			union(){
				//outer cylinders
				translate([thickness+r_mn,thickness+r_mn,0])cylinder(h=d_vh, r=r_mn+thickness,center=false);
				translate([2*thickness+3*r_mn,thickness+r_mn,0])cylinder(h=d_vh, r=r_mn+thickness,center=false);
				translate([3*thickness+5*r_mn,thickness+r_mn,0])cylinder(h=d_vh, r=r_mn+thickness,center=false);
				//translate([4*thickness+7*r_mn,+thickness+r_mn,0])cylinder(h=d_vh, r=r_mn+thickness,center=false);
				translate([4*thickness+6*r_mn+r_big,thickness+r_mn,0])cylinder(h=d_vh, r=r_big+thickness,center=false);
			}
		
			union(){
				translate([thickness+r_mn,+thickness+r_mn,thickness])cylinder(h=d_vh, r=r_mn,center=false);
				translate([2*thickness+3*r_mn,+thickness+r_mn,thickness])cylinder(h=d_vh, r=r_mn,center=false);
				translate([3*thickness+5*r_mn,+thickness+r_mn,thickness])cylinder(h=d_vh, r=r_mn,center=false);
				translate([4*thickness+6*r_mn+r_big,+thickness+r_mn,thickness])cylinder(h=d_vh, r=r_big,center=false);
			
				translate([thickness+r_mn,+thickness+r_mn,-thickness])cylinder(h=d_vh, r=r_mn/2+cl/2,center=false);
				translate([2*thickness+3*r_mn,+thickness+r_mn,-thickness])cylinder(h=d_vh, r=r_mn/2+cl/2,center=false);
				translate([3*thickness+5*r_mn,+thickness+r_mn,-thickness])cylinder(h=d_vh, r=r_mn/2+cl/2,center=false);
				translate([4*thickness+6*r_mn+r_big,+thickness+r_mn,-thickness])cylinder(h=d_vh, r=r_big/2+cl/2,center=false);
			
				// remove cylinder for tubes into valve
				translate([thickness+r_mn,thickness+r_mn+1.5*r_mn,thickness+d_vb])rotate(90,[1,0,0])cylinder(h=3*r_mn, r=r_tb,center=false);
				translate([2*thickness+3*r_mn,thickness+r_mn+1.5*r_mn,thickness+d_vb])rotate(90,[1,0,0])cylinder(h=3*r_mn, r=r_tb,center=false);
				translate([3*thickness+5*r_mn,thickness+r_mn+1.5*r_mn,thickness+d_vb])rotate(90,[1,0,0])cylinder(h=3*r_mn, r=r_tb,center=false);
				translate([4*thickness+6*r_mn+r_big,thickness+r_big,thickness+r_tb+2])rotate(90,[1,0,0])cylinder(h=2*r_big+3*thickness, r=r_tb,center=false);
			
				// remove cubes above tubes for valves
				translate([r_mn+thickness-r_tb,-(r_mn-2*thickness)/2,thickness+d_vb])cube([2*r_tb,3*r_mn,2*r_tb]);
				translate([3*r_mn+2*thickness-r_tb,-(r_mn-2*thickness)/2,thickness+d_vb])cube([2*r_tb,3*r_mn,2*r_tb]);
				translate([5*r_mn+3*thickness-r_tb,-(r_mn-2*thickness)/2,thickness+d_vb])cube([2*r_tb,3*r_mn,2*r_tb]);
				translate([6*r_mn+r_big+4*thickness-r_tb,-(r_big-1.5*thickness)/2,thickness+r_tb+2])cube([2*r_tb,2*r_big+3*thickness,3*r_tb]);
			}
		}
		// support for cutout on big valve
		translate([6*r_mn+r_big+4*thickness+6,0,0])cube([thickness,2*r_big-1,thickness+9.7]);	
	}
}

//-----------------------
// separate stand for valves, includes tray to help contain fluid leaks
//----------------------

module valve_stand_fluidcont(xp,yp,zp){

translate([xp,yp,zp])

	difference(){
		union(){
			//outer cylinders
			translate([th_v+r_mn,th_v+r_mn,0])cylinder(h=d_vh, r=r_mn+th_v,center=false);
			translate([2*th_v+3*r_mn,th_v+r_mn,0])cylinder(h=d_vh, r=r_mn+th_v,center=false);
			translate([3*th_v+5*r_mn,th_v+r_mn,0])cylinder(h=d_vh, r=r_mn+th_v,center=false);
			translate([4*th_v+7*r_mn,th_v+r_mn,0])cylinder(h=d_vh, r=r_mn+th_v,center=false);
			
			// fluid tray
			difference(){
				hull(){
					translate([2*r_mn,r_mn+th_v,0])
					difference(){
						cylinder(h=2.5*th_v,r=3*r_mn);
						translate([-3*r_mn,-3*r_mn,-0.5])cube([r_mn,6*r_mn,3*th_v]);
					}
					translate([6*r_mn+5*th_v,r_mn+th_v,0])
					rotate(180,[0,0,1])
					difference(){
						cylinder(h=2.5*th_v,r=3*r_mn);
						translate([-3*r_mn,-3*r_mn,-0.5])cube([r_mn,6*r_mn,3*th_v]);
					}
				}
				hull(){
					translate([2*r_mn,r_mn+th_v,th_v])//cylinder(h=2*th_v,r=3*r_mn-th_v);
					difference(){
						cylinder(h=2*th_v,r=3*r_mn-th_v);
						translate([-3*r_mn+th_v,-3*r_mn,-0.5])cube([r_mn,6*r_mn,3*th_v]);
					}
					translate([6*r_mn+5*th_v,r_mn+th_v,th_v])//cylinder(h=2*th_v,r=3*r_mn-th_v);
					rotate(180,[0,0,1])
					difference(){
						cylinder(h=2*th_v,r=3*r_mn-th_v);
						translate([-3*r_mn+th_v,-3*r_mn,-0.5])cube([r_mn,6*r_mn,3*th_v]);
					}
				}
			}
		}

		union(){
			// Remove interior of cylinders
			translate([th_v+r_mn,th_v+r_mn,th_v])cylinder(h=d_vh, r=r_mn,center=false);
			translate([2*th_v+3*r_mn,th_v+r_mn,th_v])cylinder(h=d_vh, r=r_mn,center=false);
			translate([3*th_v+5*r_mn,th_v+r_mn,th_v])cylinder(h=d_vh, r=r_mn,center=false);
			translate([4*th_v+7*r_mn,th_v+r_mn,th_v])cylinder(h=d_vh, r=r_mn,center=false);
		
			translate([2*th_v+3*r_mn-(thickness-th_v)/2,th_v+r_mn,-th_v])cylinder(h=d_vh, r=r_mn/2+cl/2,center=false);
			translate([3*th_v+5*r_mn+(thickness-th_v)/2,th_v+r_mn,-th_v])cylinder(h=d_vh, r=r_mn/2+cl/2,center=false);
		
			// remove cylinder for tubes into valve
			translate([th_v+r_mn,th_v+r_mn+1.5*r_mn,th_v+d_vb])rotate(90,[1,0,0])cylinder(h=3*r_mn, r=r_tb,center=false);
			translate([2*th_v+3*r_mn,th_v+r_mn+1.5*r_mn,th_v+d_vb])rotate(90,[1,0,0])cylinder(h=3*r_mn, r=r_tb,center=false);
			translate([3*th_v+5*r_mn,th_v+r_mn+1.5*r_mn,th_v+d_vb])rotate(90,[1,0,0])cylinder(h=3*r_mn, r=r_tb,center=false);
			translate([4*th_v+7*r_mn,th_v+r_mn+1.5*r_mn,th_v+d_vb])rotate(90,[1,0,0])cylinder(h=3*r_mn, r=r_tb,center=false);
		
			// remove cubes above tubes for valves
			translate([r_mn+th_v-r_tb,-(r_mn-2*th_v)/2,th_v+d_vb])cube([2*r_tb,3*r_mn,2*r_tb]);
			translate([3*r_mn+2*th_v-r_tb,-(r_mn-2*th_v)/2,th_v+d_vb])cube([2*r_tb,3*r_mn,2*r_tb]);
			translate([5*r_mn+3*th_v-r_tb,-(r_mn-2*th_v)/2,th_v+d_vb])cube([2*r_tb,3*r_mn,2*r_tb]);
			translate([7*r_mn+4*th_v-r_tb,-(r_mn-2*th_v)/2,th_v+d_vb])cube([2*r_tb,3*r_mn,2*r_tb]);
		}
	}
}

//-----------------------
// separate stand for valves -- original valves
//----------------------

module valve_stand_orig(xp,yp,zp){

translate([xp,yp,zp])

	difference(){
		union(){
			//outer cylinders
			translate([thickness+r_mn,thickness+r_mn,0])cylinder(h=d_vh, r=r_mn+thickness,center=false);
			translate([2*thickness+3*r_mn,thickness+r_mn,0])cylinder(h=d_vh, r=r_mn+thickness,center=false);
			translate([3*thickness+5*r_mn,thickness+r_mn,0])cylinder(h=d_vh, r=r_mn+thickness,center=false);
			translate([4*thickness+7*r_mn,+thickness+r_mn,0])cylinder(h=d_vh, r=r_mn+thickness,center=false);
		}
	
		union(){
			translate([thickness+r_mn,+thickness+r_mn,thickness])cylinder(h=d_vh, r=r_mn,center=false);
			translate([2*thickness+3*r_mn,+thickness+r_mn,thickness])cylinder(h=d_vh, r=r_mn,center=false);
			translate([3*thickness+5*r_mn,+thickness+r_mn,thickness])cylinder(h=d_vh, r=r_mn,center=false);
			translate([4*thickness+7*r_mn,+thickness+r_mn,thickness])cylinder(h=d_vh, r=r_mn,center=false);
		
			translate([thickness+r_mn,+thickness+r_mn,-thickness])cylinder(h=d_vh, r=r_mn/2+cl/2,center=false);
			translate([2*thickness+3*r_mn,+thickness+r_mn,-thickness])cylinder(h=d_vh, r=r_mn/2+cl/2,center=false);
			translate([3*thickness+5*r_mn,+thickness+r_mn,-thickness])cylinder(h=d_vh, r=r_mn/2+cl/2,center=false);
			translate([4*thickness+7*r_mn,+thickness+r_mn,-thickness])cylinder(h=d_vh, r=r_mn/2+cl/2,center=false);
		
			// remove cylinder for tubes into valve
			translate([thickness+r_mn,thickness+r_mn+1.5*r_mn,thickness+d_vb])rotate(90,[1,0,0])cylinder(h=3*r_mn, r=r_tb,center=false);
			translate([2*thickness+3*r_mn,thickness+r_mn+1.5*r_mn,thickness+d_vb])rotate(90,[1,0,0])cylinder(h=3*r_mn, r=r_tb,center=false);
			translate([3*thickness+5*r_mn,thickness+r_mn+1.5*r_mn,thickness+d_vb])rotate(90,[1,0,0])cylinder(h=3*r_mn, r=r_tb,center=false);
			translate([4*thickness+7*r_mn,thickness+r_mn+1.5*r_mn,thickness+d_vb])rotate(90,[1,0,0])cylinder(h=3*r_mn, r=r_tb,center=false);
		
			// remove cubes above tubes for valves
			translate([r_mn+thickness-r_tb,-(r_mn-2*thickness)/2,thickness+d_vb])cube([2*r_tb,3*r_mn,2*r_tb]);
			translate([3*r_mn+2*thickness-r_tb,-(r_mn-2*thickness)/2,thickness+d_vb])cube([2*r_tb,3*r_mn,2*r_tb]);
			translate([5*r_mn+3*thickness-r_tb,-(r_mn-2*thickness)/2,thickness+d_vb])cube([2*r_tb,3*r_mn,2*r_tb]);
			translate([7*r_mn+4*thickness-r_tb,-(r_mn-2*thickness)/2,thickness+d_vb])cube([2*r_tb,3*r_mn,2*r_tb]);
		}
	}
}

//------------
// make spout tubing brace  -- Fits on top of spout brace to hold tubing, nose cone fits at end in front of tubing brace
//-------------

module tubing_brace(xp,yp,zp){

translate([xp,yp,zp])

	union(){

		// brace for barbs to hold tubing, holds 1/8" WPI barbs
		difference(){
			union(){
				cube([barb_th+3, 2*barb_w+2*thickness+1.5, 2*barb_ht+2*thickness+gv_dpth]);		
				translate([barb_th+3,barb_w+thickness+.75,1.5*thickness])rotate(45,[0,1,0])cube([thickness, 2*barb_w+3*thickness+1.5, thickness],center=true);
				translate([0,-0.5*thickness,0])cube([barb_th+3, 0.5*thickness, 2*barb_ht+2*thickness+gv_dpth]);
				translate([0,2*barb_w+2*thickness+1.5,0])cube([barb_th+3, 0.5*thickness, 2*barb_ht+2*thickness+gv_dpth]);		
			}
			union(){
				translate([0,thickness+barb_dpth,thickness+barb_dpth])cube([barb_th+6,barb_w-2*barb_dpth,2*barb_ht+3*thickness]);
				translate([1.5,thickness,thickness])cube([barb_th,barb_w,2*barb_ht+3*thickness]);
	
				translate([0,thickness+barb_w+barb_dpth+1.5,thickness+barb_dpth])cube([barb_th+6,barb_w-2*barb_dpth,2*barb_ht+3*thickness]);
				translate([1.5,thickness+barb_w+1.5,thickness])cube([barb_th,barb_w,2*barb_ht+3*thickness]);
			}
		}
	
		// bottom of brace
		difference(){
			union(){
				translate([0,(2*barb_w+2*thickness+1.5-supp_w_top)/2-thickness,0])cube([supp_ln+l_cn_br,supp_w_top+2*thickness,1.5*thickness]);
				translate([0,(2*barb_w+2*thickness+1.5-supp_w_top)/2-thickness,0])cube([supp_ln-cl,supp_w_top+2*thickness,1.5*thickness]);
				hull(){
					translate([0,-0.5*thickness,0])cube([barb_th+3+thickness, 2*barb_w+3*thickness+1.5, 1.5*thickness]);
					translate([15,(2*barb_w+2*thickness+1.5-supp_w_top)/2-thickness,0])cube([2,supp_w_top+2*thickness,1.5*thickness]);
				}	
			}
			union(){
				lock_hole(supp_ln+l_cn_br/2,(2*barb_w+2*thickness+1.5)/2,0);
				lock_hole(supp_ln*(3/4),(2*barb_w+2*thickness+1.5)/2,0);
				lock_hole(supp_ln*(1/4),(2*barb_w+2*thickness+1.5)/2,0);
			}
		}
	
		// cylinder that fits into nose cone
		difference(){
			union(){
				translate([supp_ln+l_cn_br-2*thickness,(2*barb_w+2*thickness+1.5-supp_w_top)/2,0])cube([2*thickness,supp_w_top,center_ht-supp_ht]);
				translate([supp_ln+l_cn_br-2*thickness,(2*barb_w+2*thickness+1.5)/2,center_ht-supp_ht])rotate(90,[0,1,0])cylinder(h=2*thickness, r=supp_w_top/2);
				translate([supp_ln+l_cn_br-2*thickness,(2*barb_w+2*thickness+1.5)/2,center_ht-supp_ht])rotate(90,[0,1,0])cylinder(h=4*thickness, r=cn_diam_r/2);
			}
			union(){
				translate([supp_ln+l_cn_br-2*thickness,(2*barb_w+2*thickness+1.5-supp_w_top)/2,-thickness])cube([thickness,supp_w_top,thickness]);
				translate([supp_ln+l_cn_br-3*thickness,(2*barb_w+2*thickness+1.5)/2,center_ht-supp_ht])rotate(90,[0,1,0])cylinder(h=6*thickness, r=sp_diam/2);
			}
		}
	
		//brace at the front of the spout support
		translate([-l_cn_br,0,0])
		// round part at top of brace take difference to make sre flat on bottom
		difference(){
			union(){
				translate([supp_ln+l_cn_br-2*thickness,(2*barb_w+2*thickness+1.5-supp_w_top)/2,0])cube([2*thickness,supp_w_top,center_ht-supp_ht]);
				translate([supp_ln+l_cn_br-2*thickness,(2*barb_w+2*thickness+1.5)/2,center_ht-supp_ht])rotate(90,[0,1,0])cylinder(h=2*thickness, r=supp_w_top/2);
			}
			union(){
				translate([supp_ln+l_cn_br-2*thickness,(2*barb_w+2*thickness+1.5-supp_w_top)/2,-thickness])cube([thickness,supp_w_top,thickness]);
				translate([supp_ln+l_cn_br-3*thickness,(2*barb_w+2*thickness+1.5)/2,center_ht-supp_ht])rotate(90,[0,1,0])cylinder(h=6*thickness, r=sp_diam/2);
			}
		}
	}
}

//------
// spout shield -- protects from accidentally crossing wires with metal spout
//------

module spout_shield(xp,yp,zp,shield_th,cl) {
	translate([xp,yp,zp]) 
	difference(){
		union(){
			scale_shield(cl+shield_th);
			translate([-shield_th,-cl-shield_th-.5*thickness,0])
			difference(){
				cube([shield_th, 2*barb_w+3*thickness+1.5+2*(cl+shield_th), 2*barb_ht+2*thickness+gv_dpth+cl+shield_th]);
				translate([0,shield_th+cl+1.5,0])
				cube([shield_th, 2*barb_w+3*thickness+1.5-3, 2*barb_ht+2*thickness+gv_dpth-1]);
			}
		}
		union(){
			scale_shield(cl);
			translate([supp_ln-2*thickness+l_cn_br/2+thickness,(2*barb_w+2*thickness+1.5)/2+supp_w_top/2+5,center_ht-supp_ht])
			rotate(90,[1,0,0])cylinder(h=supp_w_top+10,r=3);
		}
	}
}

module scale_shield(sh_th) {
	//translate(xp,yp,zp) 
	union(){
		hull(){
			union(){
				// rear brace
				translate([supp_ln-2*thickness,(2*barb_w+2*thickness+1.5-supp_w_top)/2-sh_th,0])
					cube([2*thickness,supp_w_top+2*sh_th,center_ht-supp_ht]);
				translate([supp_ln-2*thickness,(2*barb_w+2*thickness+1.5)/2,center_ht-supp_ht])rotate(90,[0,1,0])
					cylinder(h=2*thickness, r=supp_w_top/2+sh_th);
				// front brace
				translate([supp_ln+l_cn_br-2*thickness,(2*barb_w+2*thickness+1.5-supp_w_top)/2-sh_th,0])
					cube([2*thickness,supp_w_top+2*sh_th,center_ht-supp_ht]);
				translate([supp_ln+l_cn_br-2*thickness,(2*barb_w+2*thickness+1.5)/2,center_ht-supp_ht])rotate(90,[0,1,0])
					cylinder(h=2*thickness, r=supp_w_top/2+sh_th);
			}
		}

		hull(){
			union(){
				// rear brace
				translate([supp_ln-3*thickness,(2*barb_w+2*thickness+1.5-supp_w_top)/2-sh_th,0])
						cube([thickness,supp_w_top+2*sh_th,center_ht-supp_ht]);
				translate([supp_ln-3*thickness,(2*barb_w+2*thickness+1.5)/2,center_ht-supp_ht])rotate(90,[0,1,0])
						cylinder(h=thickness, r=supp_w_top/2+sh_th);
				// back square
				translate([15,(2*barb_w+2*thickness+1.5-supp_w_top)/2-thickness-sh_th,0])
					cube([2,supp_w_top+2*thickness+2*sh_th,1.5*thickness]);
				translate([15,(2*barb_w+2*thickness+1.5-supp_w_top)/2-thickness-sh_th,2*barb_ht+2*thickness+gv_dpth-1.5*thickness+sh_th])
					cube([2,supp_w_top+2*thickness+2*sh_th,1.5*thickness]);	
			}	
		}			
		
		hull(){
			union(){
				// back square
				cube([barb_th+3, 2*barb_w+2*thickness+1.5, 2*barb_ht+2*thickness+gv_dpth]);	
				translate([0,-0.5*thickness-sh_th,0])cube([barb_th+3+thickness, 2*barb_w+3*thickness+1.5+2*sh_th, 1.5*thickness]);
				translate([15,(2*barb_w+2*thickness+1.5-supp_w_top)/2-thickness-sh_th,0])cube([2,supp_w_top+2*thickness+2*sh_th,1.5*thickness]);				
				translate([0,0,2*barb_ht+2*thickness+gv_dpth-1.5*thickness+sh_th]){
					translate([0,-0.5*thickness-sh_th,0])cube([barb_th+3+thickness, 2*barb_w+3*thickness+1.5+2*sh_th, 1.5*thickness]);
					translate([15,(2*barb_w+2*thickness+1.5-supp_w_top)/2-thickness-sh_th,0])cube([2,supp_w_top+2*thickness+2*sh_th,1.5*thickness]);		
				}
			}
		}
	}
}	

//---------------------
// Nose cone, fits on front of tubing brace
//----------------------

module nose_cone(xp,yp,zp) {

translate([xp,yp,zp])

	difference(){
		union(){
			difference(){
				translate([br_sq/2-supp_w_top/2-2*thickness,br_sq/2-(center_ht-supp_ht)-thickness,0])cube([supp_w_top+4*thickness,2*thickness,l_cn_br+cn_depth]);
				translate([br_sq/2-supp_w_top/2-thickness-cl/2,br_sq/2-(center_ht-supp_ht)-cl,cn_depth])cube([supp_w_top+2*thickness+cl,thickness+cl,l_cn_br]);
			}
			cube([br_sq,br_sq,thickness]);
			translate([br_sq/2,br_sq/2,0])cylinder(h=cn_depth, r1=cn_diam_i/2+thickness, r2=cn_diam_r/2+cl/2+thickness);
			
			// holders for LEDs
			translate([led_dist,br_sq-led_dist,0])cylinder(h=led_dpth, r=led_diam/2+led_wall);
			translate([br_sq-led_dist,br_sq-led_dist,0])cylinder(h=led_dpth, r=led_diam/2+led_wall);		
		}
		union(){
			translate([br_sq/2,br_sq/2,0])cylinder(h=cn_depth, r1=cn_diam_i/2, r2=cn_diam_r/2+cl/2);
			// interior of LED holders
			translate([led_dist,br_sq-led_dist,0])cylinder(h=led_dpth, r=led_diam/2);
			translate([br_sq-led_dist,br_sq-led_dist,0])cylinder(h=led_dpth, r=led_diam/2);
	
			translate([br_sq/2,br_sq/2-(center_ht-supp_ht)-thickness,cn_depth+l_cn_br/2])rotate(-90,[1,0,0])lock_hole_btm(0,0,0);
		}
	}
}

//---------------------
// bracket for holding nose cone onto cage
//----------------------

module cage_bracket(xp,yp,zp) {

	translate([xp,yp,zp])
	
	difference(){
		cube([br_sq+4*thickness,br_sq+4*thickness-led_diam-led_dist,2*thickness+cl]);
		union(){
			translate([3*thickness,3*thickness,-.5*thickness])cube([br_sq-2*thickness,br_sq-led_diam-led_dist+thickness,3*thickness]);
			translate([2*thickness-cl,2*thickness-cl,thickness])cube([br_sq+2*cl,br_sq-led_diam-led_dist+2*thickness+thickness,3*thickness]);
	
			// remove holes from flange (for epoxying)
			translate([thickness,thickness,0]){
				translate([0,0,0])cylinder(h=3*thickness,r=1);
				translate([10,0,0])cylinder(h=3*thickness,r=1);
				translate([20,0,0])cylinder(h=3*thickness,r=1);
				translate([0,10,0])cylinder(h=3*thickness,r=1);
				translate([0,20,0])cylinder(h=3*thickness,r=1);
				translate([0,30,0])cylinder(h=3*thickness,r=1);
		
				translate([br_sq+2*thickness,0,0])cylinder(h=3*thickness,r=1);
				translate([br_sq+2*thickness-10,0,0])cylinder(h=3*thickness,r=1);
				translate([br_sq+2*thickness-20,0,0])cylinder(h=3*thickness,r=1);
				translate([br_sq+2*thickness,10,0])cylinder(h=3*thickness,r=1);
				translate([br_sq+2*thickness,20,0])cylinder(h=3*thickness,r=1);
				translate([br_sq+2*thickness,30,0])cylinder(h=3*thickness,r=1);
			}
		}
	}
}

//------------------
// Make tray for tone PCB and battery
//--------------

module pcb_tray(xp,yp,zp) {

	translate([xp,yp,zp]) 

	difference(){
		union(){
			cube(size=[batt_w+pcb_l+4*th,batt_l+2*th+d_spt,d_flr+gv_dpth]);

			// brace locations 
			translate([batt_w+pcb_l+4*th-8-10,-20,th_sp])cube(size=[8,20,1.5*th]);
			translate([batt_w+pcb_l+4*th-8-13-27-10,-20,th_sp])cube(size=[13,20,1.5*th]);
			translate([batt_w+pcb_l+4*th-8-25-66-10,-20,th_sp])cube(size=[25,20,1.5*th]);
		}
		union(){
			//pcb groove	
			translate([th,th+d_spt+3,d_flr])cube(size=[pcb_l,pcb_w,d_flr+gv_dpth+2*th]);
			translate([2*th,d_spt+2*th+3,-th])cube(size=[pcb_l-2*th,pcb_w-2*th,d_flr+gv_dpth+2*th]);		

			//battery groove
			translate([th+pcb_l+2*th,th+d_spt,th])cube(size=[batt_w,batt_l,batt_th]);
			translate([th+pcb_l+4*th,th+d_spt+2*th,-th])cube(size=[batt_w-4*th,batt_l-4*th,d_flr+gv_dpth+2*th]);
			translate([3*th+pcb_l+(batt_w-batt_o)/2,d_spt+batt_l,th+3.5])cube(size=[batt_o,3*th,d_flr+gv_dpth+2*th]);
	
			//extra plastic near spout
			translate([0,0,1.5*th+th_sp])cube(size=[batt_w+pcb_l+4*th,5,2*gv_dpth]);
	
			// cutout for ground wires
			translate([pcb_l-co-th,d_spt+th,d_flr/2])cube([co,5*th,gv_dpth+d_flr]);

			// remove extra platic around pcb at edge
			translate([0,pcb_w+d_spt+5*th,-th])cube(size=[pcb_l,batt_l-pcb_w,d_flr+gv_dpth+2*th]);		
		}
	}
}

// module for removing locking holes
//--------
module lock_hole(c_x,c_y,c_z){
	translate([c_x,c_y,c_z+0.75*thickness])rotate(45,[0,0,1])cube(1.75*thickness, center=true);
	translate([c_x,c_y,c_z+1.25*thickness])rotate(45,[0,0,1])cube([2.75*thickness,2.75*thickness,thickness], center=true);
}

module lock_hole_btm(c_x,c_y,c_z){
	translate([c_x,c_y,c_z+0.5*thickness])rotate(45,[0,0,1])cube(1.75*thickness, center=true);
}

// pin for locking holes
//----------
module lock_hole_pin(c_x,c_y,c_z){
	translate([c_x+.5*thickness,c_y+.5*thickness,c_z])cube([1.75*thickness-cl/2, 1.75*thickness-cl/2,3*thickness]);
	translate([c_x,c_y,c_z])cube([2.75*thickness-cl,2.75*thickness-cl,0.5*thickness]);
	//rotate(45,[0,0,1])cube([2*thickness,2*thickness,thickness], center=true);
}


