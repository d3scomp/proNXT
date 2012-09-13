function [ VC ] = mdderslib_vehicle_constants()
    VC.wheelRadius = 0.056 / 2; % wheel radius (m)
    VC.ticksPerWheelTurn = 360;

    VC.leftWheel = [0 0.055];
    VC.rightWheel = [0 -0.055];
    VC.colorSensor = [0.09 0];
    VC.ultrasonicSensor = [0.9 0];

    VC.leftWheelInitialPos = [0.5 0.5] + VC.leftWheel;
    VC.rightWheelInitialPos = [0.5 0.5] + VC.rightWheel;    

    P = load('motorsprofile.mat');
    VC.motorProfileL = P.motorProfileL;
    VC.motorProfileR = P.motorProfileR;
end

