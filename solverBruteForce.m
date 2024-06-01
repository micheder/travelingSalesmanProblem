classdef solverBruteForce < solverTravelingSalesman
    % This class is meant for solving the traveling salesman problem in a
    % brute-force-approach. All permutations of the order of the cities to
    % be travelled are permuted and the length is calculated for each
    % permutation. The minimum length of these permutations is the solution
    % to the traveling salesman problem.

    % The class is inherited from the solverTravelingSalesman class.

    methods
        function obj = solverBruteForce(citiesObj,varargin)
            % Constructor:
            % This method creates an instance of the class 'solverBruteForce'
            %
            % input:
            % citiesObj                     handle of the object of the class cities
            % useCache                      boolean (optional): flag if cache containing the distances between tuples of cities
            %                                                   should be used for computations
            %
            % output:
            % obj                           object of the class solverBruteForce

            % handling of optional input argument; set the default value of
            % useCache to false
            if nargin < 2 || isempty(varargin{1})
                useCache = false; 
            else 
                useCache = varargin{1}; 
            end
            
            % Check that brute-force is only applied to a maximum of 10 cities
            if citiesObj.numCities > 10
                error('The brute-force is intended for demonstration purposes only for a maximum of 10 cities.')
            end

            % instantiate a solverTravelingSalesman-object (super-class)
            obj@solverTravelingSalesman(citiesObj,varargin{:});

            % solve the traveling salesman problem
            obj = obj.solve(useCache);
        end

        function obj = solve(obj,varargin)
            % This method solves the traveling salesman problem in a
            % brute-force approach. The result is the minimum total path
            % length and the order of the cities to be traveled given by
            % indices.
            %
            % input:
            % obj                           object of the class solverBruteForce
            % useCache                      boolean (optional): flag if cache containing the distances between tuples of cities
            %                                                   should be used for computations
            %
            % output:
            % obj                           object of the class solverBruteForce


            % handling of optional input argument; set the default value of
            % useCache to false
            if nargin < 2 || isempty(varargin{1})
                useCache = false; 
            else 
                useCache = varargin{1}; 
            end

            % hard-copy the timestamp of the city coordinates
            obj = obj.addTimestampCoordinatesCities;

            % vector containing the indices of the cities (pointing to the coordinates of the cities)
            cityIndicesStart = [1:obj.handleCitiesObj.numCities];
            
            % compute all permutations of city indices
            cityIndicesAllPerms = perms(cityIndicesStart);
            numPerms = size(cityIndicesAllPerms,1);
            
            % generate a traveling-path-object-array containing each permutation of city indices
            travelingPathObj = travelingPath.empty(0,numPerms);
            for k = 1:numPerms
                travelingPathObj(k) = travelingPath(obj.handleCitiesObj,cityIndicesAllPerms(k,:),useCache);
            end
            
            % find the minimum path length and the according index of the traveling-path-object-array
            [obj.minPathLength,indexMinPathLength] = min([travelingPathObj.pathLength]);
            obj.minPathCityIndices = travelingPathObj(indexMinPathLength).pathCityIndices;
        end
    end
end