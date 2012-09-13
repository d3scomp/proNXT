function [ output_args ] = pronxtsetup( input_args )
%NXTSETUP Summary of this function goes here
%   Detailed explanation goes here

root_dir = pwd;

javaaddpath('extras/bluecove-2.1.1-SNAPSHOT.jar')
javaaddpath('extras/bluecove-gpl-2.1.1-SNAPSHOT.jar')

addpath([root_dir '/extras']);
addpath([root_dir '/ecrobotNXT']);

end

