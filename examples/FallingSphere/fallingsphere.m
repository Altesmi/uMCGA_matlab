function result = fallingsphere(params)
%Simple model to calculate the position and speed of a falling sphere
%Assumes that the velocity at t=0 v(0) = 0 m/s
% INPUT:
% params: Structure containing input parameters
%   startingHeight: The distance from where the sphere is dropped [m] (ground
%   is 0 meters) 
%
%   press: air pressure [Pa]
%
%   mediumMolarMass: molar mass of the medium [kg/mol] (e.g. air 0.29
%   kg/mol)
%
%   temperature: medium and sphere temperature [K]
%
%   Cd: Drag coefficient [unitless]
%
%   radius: radius of the sphere [m]
%
%   mass: mass of the sphere [kg]
%
%   tstart: start time of the free fall
%
%   tend: end time of the free fall
%
% OUTPUT: 
% result: nx3 matrix containing the results. Columns are
% 1: time (s)
% 2: position (m)
% 3: velovity(m/s)

options = odeset('RelTol',1e-2,'AbsTol',1e-5);
initialValues = [params.startingHeight, 0];
[t,h] = ode45(@odefun,[params.tstart,params.tend],initialValues, options, params);
result = [t,h];
end

function derivatives = odefun(t,h,params)

    g = 9.81; %acceleration due to gravitation (m/s^2)
    R = 8.3145; %Universal gas constant (J/(K*mol))
    rho_medium = (params.press.*params.mediumMolarMass)./(R.*params.temperature); %density of the gaseous medium (kg/m^3)
    
    %First entry is dh/dt and the second entry is d^2h/dt^2 = dv/dt
    derivatives = [h(2);-g + 0.5.*rho_medium.*h(2).^2.*params.Cd.*4.*pi.*params.radius.^2./params.mass];

end