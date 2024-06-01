classdef travelingPath
    % This class is meant for computing the total closed path length connecting all cities
    % which are given in a specific order described by indices for the
    % property 'coordinatesCities' of an object of the class 'cities'.

    properties (GetAccess = public, SetAccess = private)
        handleCitiesObj                 % handle: handle of the related cities-object
        timestampCoordinatesCities      % double: timestamp when the coordinates of the cities were generated that were used for saving pathCityIndices
        pathCityIndices                 % integer (1 x number of cities): vector containing the indices and order of the cities to be travelled
        pathLength                      % double: the closed path length when travelling the cities in the order defined by pathCityIndices
    end

    % Public methods of this class
    methods
        function obj = travelingPath(citiesObj,pathCityIndices,varargin)
            % Constructor
            % This method creates an instance of the class 'travelingPath'
            %
            % input:
            % citiesObj                     handle of the object of the class cities
            % pathCityIndices               integer (1 x number of cities): vector containing the indices and order of the cities to be travelled
            % useCache                      boolean (optional): flag if cache containing the distances between tuples of cities
            %                                                   should be used for computations
            %
            % output:
            % obj                           object of the class travelingPath

            % handling of optional input argument; set the default value of
            % useCache to false
            if nargin < 3 || isempty(varargin{1})
                useCache = false; 
            else 
                useCache = varargin{1}; 
            end

            % Save the handle of the given instance of the 'cities'-class
            obj.handleCitiesObj = citiesObj;

            % Check that the size of the pathCityIndices vector is eqal to
            % the number of cities
            if numel(pathCityIndices) ~= obj.handleCitiesObj.numCities
                error('The number of indices pathCityIndices must conincide with the number of cities.')
            end

            % Check that there are minimum two cities as input
            if obj.handleCitiesObj.numCities < 2
                error('At travelingPath must be defined by minimum two cities.')
            end

            % Save the indices describing the order of the cities to be
            % travelled
            obj.pathCityIndices = pathCityIndices;

            % hard-copy the timestamp of the city coordinates
            obj.timestampCoordinatesCities = obj.handleCitiesObj.timestampCoordinatesCities;
    
            % compute the total path length
            obj = obj.computePathLength(useCache);
        end

        function obj = computePathLength(obj,varargin)
            % This method computes the total path length when travelling to all cities
            % in the given order
            %
            % input:
            % obj                           object of the class travelingPath
            % useCache                      boolean (optional): flag if cache containing the distances between tuples of cities
            %                                                   should be used for computations
            %
            % output:
            % obj                           object of the class travelingPath

            % handling of optional input argument; set the default value of
            % useCache to false
            if nargin < 2 || isempty(varargin{1})
                useCache = false; 
            else 
                useCache = varargin{1}; 
            end

            % compute the path length depending whether cache should be
            % used ord not
            if useCache
                obj.pathLength = obj.computePathLengthWithCache;
            else
                obj.pathLength = obj.computePathLengthWithoutCache;
            end
        end

        function isSameTimestamp = compareTimestamp(obj)
            % This method compares the timestamp when the coordinates of the cities were generated 
            % with the timestamp of the coordinates of the cities that were used during the solve method
            %
            % input:
            % obj                           object of the class travelingPath
            %
            % output:
            % isSameTimestamp               boolean: indicator if compared relevant timestamps are the same

            isSameTimestamp = obj.timestampCoordinatesCities == obj.handleCitiesObj.timestampCoordinatesCities;
        end

        function obj = plot(obj,varargin)
            % This method creates a plot of the given path
            %
            % input:
            % obj                           object of the class travelingPath
            % varargin                      additional options of the Matlab plot function
            %
            % output:
            % obj                           object of the class travelingPath

            % Compare the relevant timestamps and throw error in case of
            % manipulation
            if ~obj.compareTimestamp
                error('The timestamps of the coordinates of the cities differ. Please, re-apply solve method.')
            end

            % Coordinates of the path in correct path order
            closedPathCoordinates = obj.getClosedPathCoordinates;

            hold on
            plot(closedPathCoordinates(:,1),closedPathCoordinates(:,2),varargin{:})
            hold off
        end

        function [closedPathCoordinates] = getClosedPathCoordinates(obj)
            % This method computes the coordinates of the closed path via
            % indexing in the coordinates of the cities object
            %
            % input:
            % obj                           object of the class travelingPath
            %
            % output:
            % closedPathCoordinates         % double (numCities+1 x 2): the cartesian coordinates (x,y) of the cities with applied closed boundary condition
        
            % Apply closed boundary condition: (X_n+1 = X_1)
            closedPathIndices = obj.pathCityIndices;
            closedPathIndices(end+1) = closedPathIndices(1);
            
            % Coordinates in the order of the indices with closed boundary condition
            closedPathCoordinates = obj.handleCitiesObj.coordinatesCities(closedPathIndices,:);
        end
    end

    % Private methods of this class
    methods (Access = private)
        function [pathLength] = computePathLengthWithoutCache(obj)
            % This method computes the path length of the given path
            % defined via the order of the indices of the cities.
            %
            % input:
            % obj                           object of the class travelingPath
            %
            % output:
            % pathLength                    double: the closed path length when travelling the cities in the order defined by pathCityIndices

            % Coordinates of the path in correct path order
            closedPathCoordinates = obj.getClosedPathCoordinates;

            % Compute path length sequentially
            pathLength = 0;
            for i = [1:obj.handleCitiesObj.numCities]
                distTwoCities = norm(closedPathCoordinates(i,:) - closedPathCoordinates(i+1,:));
                pathLength = pathLength + distTwoCities;
            end
        end

        function [pathLength] = computePathLengthWithCache(obj)
            % This method computes the path length using precomputed cache.
            %
            % input:
            % obj                           object of the class travelingPath
            %
            % output:
            % pathLength                    double: the closed path length when travelling the cities in the order defined by pathCityIndices

            % Precompute the cache if it has not been computed yet.
            if ~obj.handleCitiesObj.isComputedCache
                obj.handleCitiesObj.compCacheDistTwoCities;
            end
  
            % Compute path length by "path-indexing" in the pre-computed
            % cache and consecutive summation over all sequential path
            % lengths
            indicesForPathLength = sub2ind( ...
                [obj.handleCitiesObj.numCities,obj.handleCitiesObj.numCities], ...
                obj.pathCityIndices(:), ...
                [obj.pathCityIndices(2:end).';obj.pathCityIndices(1)] ...
                );
            pathLength = sum(obj.handleCitiesObj.cacheDistTwoCities(indicesForPathLength));
        end
    end
end