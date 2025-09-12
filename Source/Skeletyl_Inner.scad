use <scad-utils/morphology.scad> //for cheaper minwoski 
use <scad-utils/transformations.scad>
use <scad-utils/shapes.scad>
use <scad-utils/trajectory.scad>
use <scad-utils/trajectory_path.scad>
include <scad-utils/linalg.scad>

use <sweep.scad>
use <../Switch.scad>
include <BOSL2/std.scad>
include <BOSL2/beziers.scad>
use <../TheHand2.scad>

//Build
Sym = false; //Override Right parameter with Left param for simpler symetric dish definition 
keycap(keyID=0, Dish=true, Stem=true, crossSection=false, visualizeDish=false, Sym=false); 

//-Parameters
wallthickness = 1.2; // 1.75 for mx size, 1.1
topthickness = 2.5; //2 for phat 3 for chicago
stepsize = 31;  //resolution of Trajectory
tranPoints = 15; //transition point for triple fade
avgWeight = 1;
fadeExpos=[2,2]; //Forward and Back exponents

bezsteps = 10;  //
step = 20;       //resolution of ellipes 
slop = 0;
fn = 32;          //resolution of Rounded Rectangles: 60 for output
layers = 20;    //resolution of vertical Sweep: 50 for output

//-Stem param
Tol    = 0.00;
stemRot = 0;
stemWid = 5.5;
stemLen = 5.5;
stemCrossHeight = 3.5;
extra_vertical  = 0.6;
StemBrimDep     = 0.25;  
stemLayers      = 30; //resolution of stem to cap top transition

keyParameters = //keyParameters[KeyID][ParameterID]
[
//  BotWid, BotLen, TWDif, TLDif, keyh, WSft, LSft  XSkew, YSkew, ZSkew, WEx, LEx, CapR0i, CapR0f, CapR1i, CapR1f, CapREx, StemEx, jog1, jog2 
   [17.16, 17.16, 4, 5, 7,  -.25,  .5,  1,  -8,   0,   2,   2,      1,      4,      1,      4,     2,       2, 0, 0], //In
];
// enum key parameters into something more legible 
function BottomWidth(keyID)  = keyParameters[keyID][0];  //
function BottomLength(keyID) = keyParameters[keyID][1];  // 
function TopWidthDiff(keyID) = keyParameters[keyID][2];  //
function TopLenDiff(keyID)   = keyParameters[keyID][3];  //
function KeyHeight(keyID)    = keyParameters[keyID][4];  //
function TopWidShift(keyID)  = keyParameters[keyID][5];
function TopLenShift(keyID)  = keyParameters[keyID][6];
function XAngleSkew(keyID)   = keyParameters[keyID][7];
function YAngleSkew(keyID)   = keyParameters[keyID][8];
function ZAngleSkew(keyID)   = keyParameters[keyID][9];
function WidExponent(keyID)  = keyParameters[keyID][10];
function LenExponent(keyID)  = keyParameters[keyID][11];
function CapRound0i(keyID)   = keyParameters[keyID][12];
function CapRound0f(keyID)   = keyParameters[keyID][13];
function CapRound1i(keyID)   = keyParameters[keyID][14];
function CapRound1f(keyID)   = keyParameters[keyID][15];
function ChamExponent(keyID) = keyParameters[keyID][16];
function StemExponent(keyID) = keyParameters[keyID][17];
function Jog1(keyID)         = keyParameters[keyID][18];
function Jog2(keyID)         = keyParameters[keyID][19];

// input for new bezier  dish shapes

//center duplicates
  //Left
//CenterLeftBezNodes0   = [[ 0,-2.], [7.3,-.5], [10.8,-1.3]];
CenterLeftBezNodes0   = [[ 0,-2.], [7.0,-.5], [9.5,-1.3]];
CenterLeftBezControl0 = let(a1=190, a2=130, a3=100)[["null"], [0, 0], [ 3.5,   0], 
                          [.5, a1], [0, 0], [.5, a1+180],
                          [1,  a2], [0, 0], ["null"]];  
//Right
CenterRightBezNodes0   = [[ 0,-2.], [6.6,-.5], [8.8,-1.3]];
CenterRightBezControl0 = let(a1=190, a2=150, a3=100)[["null"], [0, 0], [ 3.5,   0], 
                          [.5, a1], [0, 0], [.5, a1+180],
                          [1,  a2], [0, 0], ["null"]];  
 //Fwd Section 1 transition    
ForwardLeftBezNodes1   = [[ 0, -.5], [ 6.5,-1.], [8.3,-1.8]];
ForwardLeftBezControl1 = let(a1=165, a2=110)[["null"], [0, 0], [ 1,   0], 
                          [ 1,a1], [0, 0], [ .5, a1+180],
                          [ .5,a2], [0, 0], [ "null"]];
                          
ForwardRightBezNodes1   = [[ 0, -.5], [ 6.0,-1.], [8.1,-1.8]];
ForwardRightBezControl1 = let(a1=170, a2=130)[["null"], [0, 0], [ 1,   0], 
                          [ 1,a1], [0, 0], [ .5, a1+180],
                          [ .5,a2], [0, 0], [ "null"]];
                          
//Fwd Section 2 transition                          
ForwardLeftBezNodes2   = [[ 0, -.75], [ 5.4,-1.25], [7.9,-2.2]];
ForwardLeftBezControl2 = let(a1=170, a2=145)[["null"], [0, 0], [ 1,   0], 
                          [ 1.,a1], [0, 0], [1., a1+180],
                          [ 1., a2], [0, 0], [ "null"]];
                          
ForwardRightBezNodes2   = [[ 0, -.75], [ 4.8,-1.], [7.6,-1.9]];
ForwardRightBezControl2 = let(a1=170, a2=155)[["null"], [0, 0], [ 1,   0], 
                          [ 1.,a1], [0, 0], [1., a1+180],
                          [ 1., a2], [0, 0], [ "null"]];               
  //Back Section 1 transition    
BackLeftBezNodes1   = [[ 0,-2.], [8.0,-.5], [9.9,-1.3]];
BackLeftBezControl1 = let(a1=190, a2=140, a3=100)[["null"], [0, 0], [ 3.5,   0], 
                          [.5, a1], [0, 0], [.5, a1+180],
                          [1,  a2], [0, 0], ["null"]];
                          
BackRightBezNodes1   = [[ 0,-2.], [9.5,-.5], [11.,-1.3]];
BackRightBezControl1 = let(a1=190, a2=140, a3=100)[["null"], [0, 0], [ 3.5,   0], 
                          [.5, a1], [0, 0], [.5, a1+180],
                          [1,  a2], [0, 0], ["null"]];
  //Back Section 2 transition    
BackLeftBezNodes2   = [[ 0,-1.5], [8.0,-.5], [10.9,-1.3]];
BackLeftBezControl2 = let(a1=190, a2=130, a3=100)[["null"], [0, 0], [ 3.5,   0], 
                          [.5, a1], [0, 0], [.5, a1+180],
                          [1,  a2], [0, 0], ["null"]];
                          
BackRightBezNodes2   = [[ 0,-1.5], [4.2,-1.3], [6.7,-1.3]];
BackRightBezControl2 =let(a1=190, a2=130, a3=100)[["null"], [0, 0], [ 3.5,   0], 
                          [.5, a1], [0, 0], [.5, a1+180],
                          [1,  a2], [0, 0], ["null"]];                   
                   //Traj Length, Pith,Yaw, Roll 
TrajectoryArray = [[ //Forward
                     [[ 4.5, -5, 0, 0],//section 1
                     [ 6, 50, 0, 0]] //section 2
                   ],
                   [ //Backward 
                     [[-5, 3.5, 0, -0], //section 1
                     [-6.5, -20, 0, 0]] //section 2
                   ]
                  ] ;
                  
/*Rearranging Bezier data*/
bezierNodeArray = [[/*Forward*/ [/*LEFT*/ CenterLeftBezNodes0,  ForwardLeftBezNodes1,  ForwardLeftBezNodes2],
                                [/*RIGHT*/CenterRightBezNodes0, ForwardRightBezNodes1, ForwardRightBezNodes2]],
                   [/*Backward*/[/*LEFT*/ CenterLeftBezNodes0,  BackLeftBezNodes1,     BackLeftBezNodes2],
                                [/*RIGHT*/CenterRightBezNodes0, BackRightBezNodes1,    BackRightBezNodes2]]
                  ];//Array[direction][RIGHT][section],
                  
bezierControlArray = [[/*Forward*/ [/*LEFT*/ CenterLeftBezControl0,  ForwardLeftBezControl1,  ForwardLeftBezControl2],
                                   [/*RIGHT*/CenterRightBezControl0, ForwardRightBezControl1, ForwardRightBezControl2]],
                      [/*Backward*/[/*LEFT*/ CenterLeftBezControl0,  BackLeftBezControl1,     BackLeftBezControl2],
                                   [/*RIGHT*/CenterRightBezControl0, BackRightBezControl1,    BackRightBezControl2]]
                     ];//Array[direction][RIGHT][section],

//Bezier function 
function controlVec (n,b) = [ n[0]+b[0]*cos(b[1]), n[1]+b[0]*sin(b[1]) ];                               
function bezierInput (n,c) = [for(i = [1:len(c)-2])let(j=floor(i/3)) controlVec(n[j],c[i])];// for bez N=3


//skin transforms
function CapTranslation(t, keyID) = 
  [
    ((-t)/layers*TopWidShift(keyID)),   //X shift
    ((-t)/layers*TopLenShift(keyID)),   //Y shift
    (t/layers*KeyHeight(keyID))    //Z shift
  ];

function InnerTranslation(t, keyID) =
  [
    (0),   //X shift
    (0),   //Y shift
    (t/layers*(KeyHeight(keyID)-topthickness))    //Z shift
  ];

function CapRotation(t, keyID) =
  [
    ((-t)/layers*XAngleSkew(keyID)),   //X shift
    ((-t)/layers*YAngleSkew(keyID)),   //Y shift
    ((-t)/layers*ZAngleSkew(keyID))    //Z shift
  ];

function CapTransform(t, keyID) = 
  [
    pow(t/layers, WidExponent(keyID))*(BottomWidth(keyID) -TopWidthDiff(keyID)) + (1-pow(t/layers, WidExponent(keyID)))*BottomWidth(keyID) ,
    pow(t/layers, LenExponent(keyID))*(BottomLength(keyID)-TopLenDiff(keyID)) + (1-pow(t/layers, LenExponent(keyID)))*BottomLength(keyID)
  ];
function CapRoundness(t, keyID) = 
  [
    pow(t/layers, ChamExponent(keyID))*(CapRound0f(keyID)) + (1-pow(t/layers, ChamExponent(keyID)))*CapRound0i(keyID),
    pow(t/layers, ChamExponent(keyID))*(CapRound1f(keyID)) + (1-pow(t/layers, ChamExponent(keyID)))*CapRound1i(keyID)
  ];

function InnerTransform(t, keyID) = 
  [
    pow(t/layers, WidExponent(keyID))*(BottomWidth(keyID) -TopLenDiff(keyID)) + (1-pow(t/layers, WidExponent(keyID)))*(BottomWidth(keyID) -wallthickness*2),
    pow(t/layers, LenExponent(keyID))*(BottomLength(keyID)-TopLenDiff(keyID)) + (1-pow(t/layers, LenExponent(keyID)))*(BottomLength(keyID)-wallthickness*2)
  ];
  
function StemTranslation(t, keyID) =
  [
    ((t)/stemLayers*TopWidShift(keyID)),   //X shift
    (-(t)/stemLayers*TopLenShift(keyID)),   //Y shift
    stemCrossHeight+.5+StemBrimDep + (t/stemLayers*(KeyHeight(keyID)- topthickness - stemCrossHeight-.1 -StemBrimDep))    //Z shift
  ];

function StemRotation(t, keyID) =
  [
    (-(t)/stemLayers*XAngleSkew(keyID)),   //X shift
    (-(t)/stemLayers*YAngleSkew(keyID)),   //Y shift
    ((t)/stemLayers*ZAngleSkew(keyID))    //Z shift
  ];

function StemTransform(t, keyID) =
  [
    pow(t/stemLayers, StemExponent(keyID))*(BottomWidth(keyID) -TopLenDiff(keyID)) + (1-pow(t/stemLayers, StemExponent(keyID)))*(stemWid - 2*slop),
    pow(t/stemLayers, StemExponent(keyID))*(BottomLength(keyID)-TopLenDiff(keyID)) + (1-pow(t/stemLayers, StemExponent(keyID)))*(stemLen - 2*slop)
  ];
  
function StemRadius(t, keyID) = pow(t/stemLayers,3)*3 + (1-pow(t/stemLayers, 3))*1;
  //Stem Exponent 
  
  
///----- KEY Builder Module
module keycap(keyID = 0, cutLen = 0, visualizeDish = false, crossSection = CheckCross, Dish = true, SecondaryDish = false, Stem = false, StemRot = 0, homeDot = false, Stab = 0, Legends = false) {
  
  //builds
  difference(){
    union(){
      difference(){
        if(visualizeDish == true) #skin([for (i=[0:layers]) transform(translation(CapTranslation(i, keyID)) * rotation(CapRotation(i, keyID)), elliptical_rectangle(CapTransform(i, keyID), b = CapRoundness(i,keyID),fn=fn, jog1 =Jog1(keyID), jog2 = Jog2(keyID)))], slices=0); //outer shell
        else skin([for (i=[0:layers]) transform(translation(CapTranslation(i, keyID)) * rotation(CapRotation(i, keyID)), elliptical_rectangle(CapTransform(i, keyID), b = CapRoundness(i,keyID),fn=fn, jog1 =Jog1(keyID), jog2 = Jog2(keyID)))], slices=0); //outer shell
        //Cut inner shell
        if(Stem == true){ 
          translate([0,0,-.001])skin([for (i=[0:layers]) transform(translation(InnerTranslation(i, keyID)) * rotation(CapRotation(i, keyID)), elliptical_rectangle(InnerTransform(i, keyID), b = CapRoundness(i,keyID),fn=fn, jog1 =Jog1(keyID), jog2 = Jog2(keyID)))], slices=0);
//skin([for (i=[0:layers]) transform(translation(InnerTranslation(i, keyID)) * rotation(CapRotation(i, keyID)), elliptical_rectangle_stem(InnerTransform(i, keyID), b = CapRoundness(i,keyID),fn=fn))], slices=0);
        }
      }
      if(Stem == true){
        translate([0,0,StemBrimDep])rotate(stemRot)difference(){   
          //cylinderical Stem body 
          cylinder(d =5.5,KeyHeight(keyID)-StemBrimDep, $fn= 32);
          skin(StemCurve, slices=0);
          skin(StemCurve2, slices=0);
        }
        translate([0,0,-.001])skin([for (i=[0:stemLayers-1]) transform(translation(StemTranslation(i,keyID))*rotation(StemRotation(i, keyID)), elliptical_rectangle_stem(StemTransform(i, keyID),b=[5.5,5.5], fn=8))],slices=0); //Transition Support for taller profilea
     }
    //cut for fonts and extra pattern for light?

    }
    
    //Cuts
    
    //Fonts
    if(cutLen != 0){
      translate([sign(cutLen)*(BottomLength(keyID)+CapRound0i(keyID)+abs(cutLen))/2,0,0])
        cube([BottomWidth(keyID)+CapRound1i(keyID)+1,BottomLength(keyID)+CapRound0i(keyID),50], center = true);
    }
    if(Legends ==  true){
      #rotate([-XAngleSkew(keyID),YAngleSkew(keyID),ZAngleSkew(keyID)])translate([-1,-5,KeyHeight(keyID)-2.5])
        linear_extrude(height = 1)text( text = "ver2", font = "Constantia:style=Bold", size = 3, valign = "center", halign = "center" );
      }
      
   //Dish Shape 
    if(Dish == true){
    for(i= [0:len(TrajectoryArray)-1]) {
      for(j=[0:len(TrajectoryArray[i])-1]){
        let(jumpMatrix = j==0?nullJump:generateTrajectory(i,j-1)[stepsize-1])// swap to recursive multip since it only jumps locally 
        #translate([-TopWidShift(keyID),-TopLenShift(keyID),KeyHeight(keyID)-0])rotate([0,-YAngleSkew(keyID),0])rotate([90-XAngleSkew(keyID),0,0-ZAngleSkew(keyID)]){
          skin(bezTransform (directions=i, sections =j, jump= jumpMatrix, fadeExpo=fadeExpos[i], topBoundry =1.5), slices =0);
        }
      }
    }


   }
     if(crossSection == true) {
       translate([0,-25,-.1])cube([15,50,15]); 
     }
  }
  //Homing dot
  if(homeDot == true)translate([0,0,KeyHeight(keyID)-DishHeightDif(keyID)-.25])sphere(d = 1);
  
  if(visualizeDish == true){
//      #translate([-TopWidShift(keyID),-TopLenShift(keyID),KeyHeight(keyID)-0])
    for(i= [0:len(TrajectoryArray)-1]) {
      for(j=[0:len(TrajectoryArray[i])-1]){
        let(jumpMatrix = j==0?nullJump:generateTrajectory(i,j-1)[stepsize-1])// swap to recursive multip since it only jumps locally 
        translate([-TopWidShift(keyID),-TopLenShift(keyID),KeyHeight(keyID)-0])rotate([0,-YAngleSkew(keyID),0])rotate([90-XAngleSkew(keyID),0,0-ZAngleSkew(keyID)]){
          skin(bezTransform (directions=i, sections =j, jump= jumpMatrix, fadeExpo=fadeExpos[i], topBoundry = -4), slices =0);
        }
      }
    }
    //draw out bezier curve at each sector 
    translate([-TopWidShift(keyID),-TopLenShift(keyID),KeyHeight(keyID)-0])rotate([0,-YAngleSkew(keyID),0])rotate([90-XAngleSkew(keyID),0,0-ZAngleSkew(keyID)]){
      for(i= [0:len(TrajectoryArray)-1]) {
        for(j=[0:len(TrajectoryArray[i])-1]){// once to the end and once at tranpoints
          let(jumpParam1 = rot_decode(recur_jump(j+1, direction=i, jumpInit=nullJump, jumpStep=stepsize-1)), jumpParam2 = rot_decode(recur_jump(j+1, direction=i, jumpInit=nullJump, jumpStep=tranPoints)),RIGHT = 0, LEFT = 1, n= j+1)// swap to recursive multip since it only jumps locally 
          {
            //end section 
            move(jumpParam1[3])rot(a=jumpParam1[0],v=jumpParam1[1],cp=jumpParam1[2]){
              mirror([1,0,0])debug_bezier(bezierInput(bezierNodeArray[i][RIGHT][n+1], bezierControlArray[i][RIGHT][n+1]),N=3, width = .1); // draw bezier curve for sanity check
              debug_bezier(bezierInput(bezierNodeArray[i][LEFT][n+1], bezierControlArray[i][LEFT][n+1]),N=3, width = .1); // draw bezier curve for sanity check
              color("gold")back(1)text( text = str(i==0?"Fwd ":"Back ", n+1), font = "Constantia:style=Bold", size = 1, valign = "center", halign = "center" );
              }
             // transition point
             move(jumpParam2[3])rot(a=jumpParam2[0],v=jumpParam2[1],cp=jumpParam2[2]){
               mirror([1,0,0])debug_bezier(bezierInput(bezierNodeArray[i][RIGHT][n], bezierControlArray[i][RIGHT][n]),N=3, width = .1); // draw bezier curve for sanity check
               debug_bezier(bezierInput(bezierNodeArray[i][LEFT][n], bezierControlArray[i][LEFT][n]),N=3, width = .1); // draw bezier curve for sanity check
               color("gold")back(1)text( text = str(i==0?"Fwd ":"Back ", n), font = "Constantia:style=Bold", size = 1, valign = "center", halign = "center" );
              }
         }
    }}
    //Center piece
      mirror([1,0,0])debug_bezier(bezierInput(bezierNodeArray[0][0][0], bezierControlArray[0][0][0]),N=3, width = .1); // draw bezier curve for sanity check
      debug_bezier(bezierInput(bezierNodeArray[0][1][0], bezierControlArray[0][1][0]),N=3, width = .1); // draw bezier curve for sanity check
      color("gold")back(1)text( text = str("Center ", 0), font = "Constantia:style=Bold", size = 1, valign = "center", halign = "center" );
    }
  }
}

//------------------stems 

MXWid = 4.20/2+Tol; //horizontal lenght
MXLen = 4.00/2+Tol; //vertical length

MXWidT = 1.15/2+Tol; //horizontal thickness
MXLenT = 1.25/2+Tol; //vertical thickness

function stem_internal(sc=1) = sc*[
[MXLenT, MXLen],[MXLenT, MXWidT],[MXWid, MXWidT],
[MXWid, -MXWidT],[MXLenT, -MXWidT],[MXLenT, -MXLen],
[-MXLenT, -MXLen],[-MXLenT, -MXWidT],[-MXWid, -MXWidT],
[-MXWid,MXWidT],[-MXLenT, MXWidT],[-MXLenT, MXLen]
];  //2D stem cross with tolance offset and additonal transformation via jog 
//trajectory();
function StemTrajectory() = 
  [
    trajectory(forward = 5.25)  //You can add more traj if you wish 
  ];
  
  StemPath  = quantize_trajectories(StemTrajectory(),  steps = 1 , loop=false, start_position= $t*4);
  StemCurve  = [ for(i=[0:len(StemPath)-1])  transform(StemPath[i],  stem_internal()) ];

function StemTrajectory2() = 
  [
    trajectory(forward = .5)  //You can add more traj if you wish 
  ];
  
  StemPath2  = quantize_trajectories(StemTrajectory2(),  steps = 10, loop=false, start_position= $t*4);
  StemCurve2  = [ for(i=[0:len(StemPath2)-1])  transform(StemPath2[i]*scaling([(1.1-.1*i/(len(StemPath2)-1)),(1.1-.1*i/(len(StemPath2)-1)),1]),  stem_internal()) ]; 

module choc_stem(draftAng = 5) {
  stemHeight = 3.1;
  dia = .15;
  wids = 1.2/2;
  lens = 2.9/2; 
  module Stem() {
    difference(){
      translate([0,0,-stemHeight/2])linear_extrude(height = stemHeight)hull(){
        translate([wids-dia,-3/2])circle(d=dia);
        translate([-wids+dia,-3/2])circle(d=dia);
        translate([wids-dia, 3/2])circle(d=dia);
        translate([-wids+dia, 3/2])circle(d=dia);
      }
    //cuts
      translate([3.9,0])cylinder(d1=7+sin(draftAng)*stemHeight, d2=7,3.5, center = true, $fn = 64);
      translate([-3.9,0])cylinder(d1=7+sin(draftAng)*stemHeight,d2=7,3.5, center = true, $fn = 64);
    }
  }

  translate([5.7/2,0,-stemHeight/2+2])Stem();
  translate([-5.7/2,0,-stemHeight/2+2])Stem();
}

//shape functions
function rounded_rectangle_profile(size=[1,1],r=1,fn=32) = [
	for (index = [0:fn-1])
		let(a = index/fn*360) 
			r * [cos(a), sin(a)] 
			+ sign_x(index, fn) * [size[0]/2-r,0]
			+ sign_y(index, fn) * [0,size[1]/2-r]
];
//Mix (a, b, t, steps, pows)
  
function elliptical_rectangle(a = [1,1], b =[1,1], fn=32, jog1 = 2, jog2 = 2) = [
    for (index = [0:fn-1]) // section right
     let(theta1 = -atan(a[1]/b[1])+ 2*atan(a[1]/b[1])*index/fn, 
         theta_rot = -0, 
         EllipseFront = [b[1]*cos(theta1), a[1]*sin(theta1)] + [a[0]*cos(atan(b[0]/a[0]))    , 0]- [b[1]*cos(atan(a[1]/b[1])), 0],
         EllipseBack  = [b[1]*cos(theta1), a[1]*sin(theta1)] + [a[0]*cos(atan(b[0]/a[0]))+jog1, 0]- [b[1]*cos(atan(a[1]/b[1])), 0]) 
      smoothStep(EllipseFront, EllipseBack, index, fn-1),
//        [b[1]*cos(theta1)*cos(theta_rot)- a[1]*sin(theta1)*sin(theta_rot), b[1]*cos(theta1)*sin(theta_rot) + a[1]*sin(theta1)*cos(theta_rot)]

    for(index = [0:fn-1]) // section Top
     let(theta2 = atan(b[0]/(a[0])) + (180 -2*atan(b[0]/(a[0])))*index/fn) 
      [(a[0]+(jog1+jog2)/2)*cos(theta2)+(jog1+jog2)/2-jog2, b[0]*sin(theta2)]
    - [0, b[0]*sin(atan(b[0]/(a[0])))]
    + [0, a[1]*sin(atan(a[1]/b[1]))],

    for(index = [0:fn-1]) // section left
     let(theta2 = -atan(a[1]/b[1])+180+ 2*atan(a[1]/b[1])*index/fn,
         EllipseFront = [b[1]*cos(theta2), a[1]*sin(theta2)] - [a[0]*cos(atan(b[0]/a[0]))+jog2, 0] + [b[1]*cos(atan(a[1]/b[1])) , 0],
         EllipseBack  = [b[1]*cos(theta2), a[1]*sin(theta2)] - [a[0]*cos(atan(b[0]/a[0]))    , 0] + [b[1]*cos(atan(a[1]/b[1])) , 0]
     ) 
     smoothStep(EllipseFront, EllipseBack, index, fn-1),
    
    for(index = [0:fn-1]) // section Bottom
     let(theta2 = atan(b[0]/a[0]) + 180 + (180 -2*atan(b[0]/a[0]))*index/fn) 
      [a[0]*cos(theta2), b[0]*sin(theta2)]
    + [0, b[0]*sin(atan(b[0]/a[0]))]
    - [0, a[1]*sin(atan(a[1]/b[1]))]
]/2;

function elliptical_rectangle_stem(a = [1,1], b =[1,1], fn=32) = [
    for (index = [0:fn-1]) // section right
     let(theta1 = -atan(a[1]/b[1])+ 2*atan(a[1]/b[1])*index/fn) 
      [b[1]*cos(theta1), a[1]*sin(theta1)]
    + [a[0]*cos(atan(b[0]/a[0])) , 0]
    - [b[1]*cos(atan(a[1]/b[1])) , 0],
    
    for(index = [0:fn-1]) // section Top
     let(theta2 = atan(b[0]/a[0]) + (180 -2*atan(b[0]/a[0]))*index/fn) 
      [a[0]*cos(theta2), b[0]*sin(theta2)]
    - [0, b[0]*sin(atan(b[0]/a[0]))]
    + [0, a[1]*sin(atan(a[1]/b[1]))],

    for(index = [0:fn-1]) // section left
     let(theta2 = -atan(a[1]/b[1])+180+ 2*atan(a[1]/b[1])*index/fn) 
      [b[1]*cos(theta2), a[1]*sin(theta2)]
    - [a[0]*cos(atan(b[0]/a[0])) , 0]
    + [b[1]*cos(atan(a[1]/b[1])) , 0],
    
    for(index = [0:fn-1]) // section Top
     let(theta2 = atan(b[0]/a[0]) + 180 + (180 -2*atan(b[0]/a[0]))*index/fn) 
      [a[0]*cos(theta2), b[0]*sin(theta2)]
    + [0, b[0]*sin(atan(b[0]/a[0]))]
    - [0, a[1]*sin(atan(a[1]/b[1]))]
]/2;
function sign_x(i,n) = 
	i < n/4 || i > n-n/4  ?  1 :
	i > n/4 && i < n-n/4  ? -1 :
	0;

function sign_y(i,n) = 
	i > 0 && i < n/2  ?  1 :
	i > n/2 ? -1 :
	0;
  
//------- function defining Dish Shapes
//helper function
function Flip (singArry) = [for(i = [len(singArry)-1:-1:0]) singArry[i]];   
function mirrorX (singArry) = [for(i = [len(singArry)-1:-1:0]) [-singArry[i][0], singArry[i][1]]];   
function mirrorY (singArry) = [for(i = [len(singArry)-1:-1:0]) [singArry[i][0], -singArry[i][1]]];  
  

  
function Mix (a, b, t, steps, pows)= (1-pow(t/steps, pows))*a+pow(t/steps, pows)*b;
function smoothStart (init, fin, t, steps, power) = 
  (1-pow(t/steps,power))*init + pow(t/steps,power)*fin ; 

function smoothStop (init, fin, t, steps, power) = 
  (fin-init)*(1-pow(1-t/steps,power))+init; 

function smoothStep (init, fin, t, steps) = 
  (fin - init)*(pow(t/steps,2)*3 - pow(t/steps,3)*2) + init; 

function smootherStep (init, fin, t, steps) = 
  (fin - init)*(6*pow(t/steps,5) - 15*pow(t/steps,4) +10* pow(t/steps,3)) + init; 

function smoothestStep (init, fin, t, steps) = 
  (fin - init)*(-20*pow(t/steps,7) + 70*pow(t/steps,6) - 84*pow(t/steps,5) +35*pow(t/steps,4)) + init; 
function ellipse(a, b, d = 0, rot1 = 0, rot2 = 360) = [for (n = [0:step])let (t = rot1 + n*(rot2-rot1)/step) [a*cos(t)+a, b*sin(t)*(1+d*cos(t))]]; //Centered at a apex to avoid inverted face

function smoothPeak(init, cent, fin, t, steps, transitionPoint) = t <= transitionPoint ?  smoothStep(init,cent, t, transitionPoint) :  smoothStep(cent, fin, t-transitionPoint, steps-transitionPoint);

function Fade (Arry1, Arry2, t, steps, pows) =len(Arry1)==len(Arry2) ? [for(i = [0:len(Arry1)-1]) (1-pow(t/steps, pows))*Arry1[i]+pow(t/steps, pows)*Arry2[i]]: [[0,0]];


function DishTransition (Arry1, Arry2, t, steps, pows) =len(Arry1)==len(Arry2) ? [for(i = [0:len(Arry1)-1]) 
    [Mix(Arry1[i][0], Arry2[i][0],t,steps,pows),
//     Mix(Arry1[i][1], Arry2[i][1],t,steps,1) ]]: 
     smoothestStep(Arry1[i][1], Arry2[i][1],t,steps) ]]: 
    [[0,0]];
    
    
function TripleFade (Arry1, Arry2, Arry3, t, steps, pows, transitionPoint=step/2) =len(Arry1)==len(Arry2) ? [for(i = [0:len(Arry1)-1]) smoothPeak(Arry1[i], Arry2[i], Arry3[i], t, steps, transitionPoint) ]: [[0,0]];
             
function Average (Arry1, Arry2, weight=.5) = len(Arry1)==len(Arry2) ? [for(i = [0:len(Arry1)-1]) weight*Arry1[i] + (1-weight)*Arry2[i] ]: [[0,0]];

 //generated 
//generalized trajectory call with array table Foo[forward/backward direction][left/right directione][shapetransforms inputs][trajectoryinputs]            
function generateTrajectory(direction=0, section=0) = quantize_trajectories( 
  [for( i = [0:len(TrajectoryArray[direction][section])-1]) let(table = TrajectoryArray[direction][section][i]) trajectory(forward = table[0], yaw =table[1], pitch =table[2], roll = table[3])], 
  steps = stepsize, loop = false);
  
function generateDishShape (direction=0, section=0, topBoundry) = let(RIGHT = 0, LEFT = 1) concat( 
  [[-pointlist_bounds(bezierNodeArray[direction][RIGHT][section])[1][0], topBoundry]],  //edge point
  
    mirrorX(bezpath_curve(bezierInput(bezierNodeArray[direction][RIGHT][section], bezierControlArray[direction][RIGHT][section]), splinesteps = bezsteps, N = 3)),
    
    bezpath_curve(bezierInput(bezierNodeArray[direction][LEFT][section], bezierControlArray[direction][LEFT][section]), splinesteps = bezsteps, N = 3),
    
  [[pointlist_bounds(bezierNodeArray[direction][LEFT][section])[1][0], topBoundry]],  //edge point
  );  //sanity check required

  nullJump = [[1,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,1]]; //vec of no translation for transform shift

//  echo(generateDishShape(topBoundry=5)[0]*2);
  echo(Fade(generateDishShape(1, 0, 2), generateDishShape(1, 0+2, 2),0,stepsize-1,1));
  echo(FadeXY(generateDishShape(1, 0, 2), generateDishShape(1, 0+2, 2),0,stepsize-1,1));
  //what to split XY on MIX or Fade
function bezTransform (directions=0, sections =0, jump= nullJump, fadeExpo=2, topBoundry = 1) = [for(i=[0:stepsize-1]) transform(jump*generateTrajectory(directions,sections)[i], 
//Average(
//  FadeXY(generateDishShape(directions, sections, topBoundry), generateDishShape(directions, sections+2, topBoundry),i,stepsize-1,fadeExpo),
//  TripleFade(generateDishShape(directions, sections, topBoundry),generateDishShape(directions, sections+1, topBoundry),generateDishShape(directions, sections+2, topBoundry), i, stepsize-1, fadeExpo, tranPoints),
//  weight= avgWeight))
  DishTransition(generateDishShape(directions, sections, topBoundry), generateDishShape(directions, sections+2, topBoundry),i,stepsize-1,fadeExpo))
];

function recur_jump (n, direction=0, jumpInit=nullJump, jumpStep) = n==0? jumpInit: recur_jump(n-1, direction, generateTrajectory(direction,n-1)[jumpStep]*jumpInit); //transform matrix to nth dish trajectory start point




/*  TODOS
update plan R3 + R2/4  and Lat 
1u alphas  
Corne Plus
Cornelius
Skeletyl A
Skeletyl B 
2u bars/ kenesis 

*/



























