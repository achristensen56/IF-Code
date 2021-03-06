
classdef ForcedChoice2 < handle
    properties (SetAccess=private)
        params
    end
    
    properties (Hidden=true)
        a % Arduino object
    end
    
    methods
        function choice = ForcedChoice2(comPort)
            % Set up parameters
            %------------------------------------------------------------
                              
            % JP1
            p.corridor(1).step = 53;  % Dir is expected to be pin "step"-2
            p.corridor(1).dose = 49;
            p.corridor(1).dose_duration = 200;
            p.corridor(1).lick = 47;
            
            
            
            % JP3
            % Callibration by Shai on 4/19/2016. dose_duration = 50 ms 
            %   gives 130 doses per 1 mL (7.7 uL)
            p.corridor(2).step = 29;
            p.corridor(2).dose = 25;
            p.corridor(2).dose_duration = 50; % ms
            p.corridor(2).lick = 23;
            
            p.trial_out = 22;
            p.response_window = 24;
            
            p.num_corridors = length(p.corridor);
            
            choice.params = p;
            
            % Establish access to Arduino
            %------------------------------------------------------------
            choice.a = arduino(comPort);

            % Set up digital pins
            for i = 1:length(choice.params.corridor)
                corridor = choice.params.corridor(i);
                choice.a.pinMode(corridor.step, 'output');
                choice.a.pinMode(corridor.step-2, 'output'); % dir
                choice.a.pinMode(corridor.dose, 'output');
                choice.a.pinMode(corridor.lick, 'input');
            end
            
            choice.a.pinMode(choice.params.trial_out, 'output');
            choice.a.pinMode(choice.params.response_window, 'output');
             
        end        
        
        function dose(choice, corridor_ind)
            c = choice.params.corridor(corridor_ind); % Selected corridor
            choice.a.send_pulse(c.dose, c.dose_duration);
        end % dose
        
        function lick = is_licking(choice, corridor_ind)
            %lick_pin = choice.params.corridor(corridor_ind).lick;
            val = choice.a.roundTrip(corridor_ind);
            lick = (val == 0); % HW pin goes low for lick
        end % is_licking
        
        function lick_state = get_lick_state(choice)
            lick_state = zeros(1, choice.params.num_corridors);
            for i = 1:choice.params.num_corridors
                lick_state(i) = choice.is_licking(i);
            end
        end % get_lick_state
       
        function set_trial_out(choice, val)
            choice.a.digitalWrite(choice.params.trial_out, val);
        end
        function set_response_window(choice, val)
            choice.a.digitalWrite(choice.params.response_window, val);
        end
    end
end