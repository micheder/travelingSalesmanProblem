classdef solverSimulatedAnnealing < solverTravelingSalesman
    % This class is meant for solving the traveling salesman problem using
    % the Simulated Annealing method, which is a Markov chain Monte Carlo
    % method.
    % For further information on the implemented algorithm, see 
    % https://en.wikipedia.org/wiki/Simulated_annealing

    % The class is inherited from the solverTravelingSalesman class.

    methods
        function obj = solverSimulatedAnnealing(citiesObj,varargin)
            % Constructor
            % This method creates an instance of the class 'solverSimulatedAnnealing'
            %
            % input:
            % citiesObj                     handle of the object of the class cities
            % useCache                      boolean (optional): flag if cache containing the distances between tuples of cities
            %                                                   should be used for computations
            %
            % output:
            % obj                           object of the class solverSimulatedAnnealing

            % handling of optional input argument; set the default value of
            % useCache to false
            if nargin < 2 || isempty(varargin{1})
                useCache = false; 
            else 
                useCache = varargin{1}; 
            end

            % instantiate a solverTravelingSalesman-object (super-class)
            obj@solverTravelingSalesman(citiesObj,varargin{:});

            % solve the traveling salesman problem
            obj = obj.solve(useCache);
        end

        function obj = solve(obj,varargin)
            % This method solves the traveling salesman problem with the
            % Simulated Annealing method. The result is the minimum total path
            % length and the order of the cities to be traveled given by
            % indices.
            %
            % input:
            % obj                           object of the class solverSimulatedAnnealing
            % useCache                      boolean (optional): flag if cache containing the distances between tuples of cities
            %                                                   should be used for computations
            %
            % output:
            % obj                           object of the class solverSimulatedAnnealing

            % handling of optional input argument; set the default value of
            % useCache to false
            if nargin < 2 || isempty(varargin{1})
                useCache = false; 
            else 
                useCache = varargin{1}; 
            end

            % hard-copy the timestamp of the city coordinates
            obj = obj.addTimestampCoordinatesCities;

            %% Initializations for the Markov chain Monte Carlo simulation:

            % select starting temperature for simulated annealing
            % simulation
            tempStart = 1;

            % select number of steps within the simulated annealing
            % simulation with constant temperature (squared number of cities)
            numStepsConstTemp = obj.handleCitiesObj.numCities^2;

            % number of temperature sequences
            numTempSeq = 300;

            % vector containing the temperatures
            tempVec = nan(numTempSeq,1);
            
            % vector containing the indices of the cities (pointing to the coordinates of the cities)
            cityIndicesStart = [1:obj.handleCitiesObj.numCities];

            % generate a traveling-path-object-array containing
            % each step in the Markov chain
            travelingPathObj = travelingPath.empty(0,numStepsConstTemp);
            
            % instantiate first object in the Markov chain containing
            % travaling-path-objects
            travelingPathObj(1) = travelingPath(obj.handleCitiesObj,cityIndicesStart,useCache);
            
            %% loop over various temperatures
            for k = 1:numTempSeq
                
                % compute temperature for one sequence with constant
                % temperature
                tempVec(k) = tempStart * k^(-1);

                % create a Markov chain for a constant temperature
                for j = 1:numStepsConstTemp

                    % propose two cities for commutation
                    propCommuteCityIndices = solverSimulatedAnnealing.propTwoRandCites(obj.handleCitiesObj);

                    % compute the delta of the path length that is
                    % obtained, when these two cities are commuted in the given path
                    deltaPathLength = solverSimulatedAnnealing.compDeltaPathLengthCommutation(obj.handleCitiesObj,travelingPathObj(j).pathCityIndices,propCommuteCityIndices);

                    if min(1,exp(-1/tempVec(k) * deltaPathLength)) > rand
                        cityIndices = solverSimulatedAnnealing.commutePathCityIndices(travelingPathObj(j).pathCityIndices,propCommuteCityIndices);
                        travelingPathObj(j+1) = travelingPath(obj.handleCitiesObj,cityIndices,useCache);
                    else
                        travelingPathObj(j+1) = travelingPathObj(j);
                    end
                end

                % find the minimum path length and the according index of the traveling-path-object-array
                [~,indexMinPathLength] = min([travelingPathObj.pathLength]);

                % instantiate first object in the Markov chain for the next temperature:
                % the shortest travaling-path for this temperature
                % configuration is the first starting configuration for the
                % next temperature
                travelingPathObj(1) = travelingPath(obj.handleCitiesObj,travelingPathObj(indexMinPathLength).pathCityIndices,useCache);        
            end

            % save the minimum path-length and the traveling path as result
            % of the solver
            [obj.minPathLength,indexMinPathLength] = min([travelingPathObj.pathLength]);
            obj.minPathCityIndices = travelingPathObj(indexMinPathLength).pathCityIndices;
        end
    end

    % Helper methods for this class
    methods (Access = private, Static = true)
        function propCityIndices = propTwoRandCites(handleCitiesObj)
            % This method randomly proposes the indices of two cities in ascending order
            %
            % input:
            % handleCitiesObj               handle of the object of the class cities
            %
            % output:
            % propCityIndices               integer (2 x 1): vector containing the indices of two proposed cities in ascending order

            propCityIndices = sort(randi([1,handleCitiesObj.numCities],2,1));
        end

        function deltaPathLength = compDeltaPathLengthCommutation(handleCitiesObj,pathCityIndices,propCommuteCityIndices)
            % This method computes the delta of the path length that is
            % obtained, when two cities are exchanged in the given path
            %
            % input:
            % handleCitiesObj               handle of the object of the class cities
            % pathCityIndices               integer (1 x number of cities): vector containing the indices and order of the cities to be travelled
            % propCommuteCityIndices        integer (2 x 1): vector containing the indices of two randomly proposed cities in ascending order
            %
            % output:
            % deltaPathLength               double: delta of the path length that is obtained, when two cities are exchanged in the proposed manner

            % Compute the indices of the proposed cities (indexing the
            % coordinates)
            cityCommuteIndexA = pathCityIndices(propCommuteCityIndices(1));
            cityCommuteIndexB = pathCityIndices(propCommuteCityIndices(2));

            % Compute the indices of the neighbouring cities A_-1 and B_+1
            % assuming that A < B
            if propCommuteCityIndices(1) == 1
                cityCommuteIndexAMinus1 = pathCityIndices(end);
            else
                cityCommuteIndexAMinus1 = pathCityIndices(propCommuteCityIndices(1)-1);
            end
            
            if propCommuteCityIndices(2) == handleCitiesObj.numCities
                cityCommuteIndexBPlus1 = pathCityIndices(1);
            else
                cityCommuteIndexBPlus1 = pathCityIndices(propCommuteCityIndices(2)+1);
            end

            % Compute the delta of the path length via indexing the
            % coordinates
            deltaPathLength = norm(handleCitiesObj.coordinatesCities(cityCommuteIndexAMinus1,:) - handleCitiesObj.coordinatesCities(cityCommuteIndexB,:)) + ...
                              norm(handleCitiesObj.coordinatesCities(cityCommuteIndexA,:) - handleCitiesObj.coordinatesCities(cityCommuteIndexBPlus1,:)) - ...
                              norm(handleCitiesObj.coordinatesCities(cityCommuteIndexAMinus1,:) - handleCitiesObj.coordinatesCities(cityCommuteIndexA,:)) - ... 
                              norm(handleCitiesObj.coordinatesCities(cityCommuteIndexB,:) - handleCitiesObj.coordinatesCities(cityCommuteIndexBPlus1,:));
        end

        function commutedPathCityIndices = commutePathCityIndices(pathCityIndices,propCommuteCityIndices)
            % This method computes the path of city indices, when two
            % cities are commuted (meaning that the sub-path or sequence between these two cities is inverted)
            %
            % input:
            % pathCityIndices               integer (1 x number of cities): vector containing the indices and order of the cities to be travelled
            % propCommuteCityIndices        integer (2 x 1): vector containing the indices of two randomly proposed cities in ascending order
            %
            % output:
            % commutedPathCityIndices       integer (1 x number of cities): vector containing the indices and order of the cities after commuting as proposed

            % select the sequence of indices between the propos two city indices
            seq = pathCityIndices(propCommuteCityIndices(1):propCommuteCityIndices(2));
           
            % commute the sequence of indices within the path of city indices:
            commutedPathCityIndices = pathCityIndices;
            commutedPathCityIndices(propCommuteCityIndices(1):propCommuteCityIndices(2)) = fliplr(seq);
        end
    end
end