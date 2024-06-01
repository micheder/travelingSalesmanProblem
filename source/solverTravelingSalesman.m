classdef (Abstract) solverTravelingSalesman
    % This class is meant as a super-class for all traveling salesman
    % problem solvers. This class is an abstract class, meaning that the
    % class cannot be instantiated directly. A unique implementation as
    % a sub-class is required.

    properties (GetAccess = public, SetAccess = protected)
        handleCitiesObj                 % handle: handle of the related cities-object
        timestampCoordinatesCities      % double: timestamp when the coordinates of the cities were generated that were used during the solve method
        minPathCityIndices              % integer (1 x number of cities): vector containing the resulting indices and order of the cities to be travelled for minimum path length
        minPathLength                   % double: the closed minimum path length when travelling the cities in the order defined by minPathCityIndices
    end

    methods
        function obj = solverTravelingSalesman(citiesObj,varargin)
            % Constructor
            % This method creates an instance of the super-class 'solverTravelingSalesman'
            %
            % input:
            % citiesObj                     handle of the object of the class cities
            % useCache                      boolean (optional): flag if cache containing the distances between tuples of cities
            %                                                   should be used for computations
            %
            % output:
            % obj                           object of the class solverTravelingSalesman (cannot be instantiated directly due to abstract class)

            % handling of optional input argument; set the default value of
            % useCache to false
            if nargin < 2 || isempty(varargin{1})
                useCache = false; 
            else 
                useCache = varargin{1}; 
            end

            % save the handle of the given instance of the 'cities'-class
            obj.handleCitiesObj = citiesObj;
        end

        function isSameTimestamp = compareTimestamp(obj)
            % This method compares the timestamp when the coordinates of the cities were generated 
            % with the timestamp of the coordinates of the cities that were used during the solve method
            %
            % input:
            % obj                           object of the class solverTravelingSalesman
            %
            % output:
            % isSameTimestamp               boolean: indicator if compared relevant timestamps are the same

            isSameTimestamp = obj.timestampCoordinatesCities == obj.handleCitiesObj.timestampCoordinatesCities;
        end

        function obj = plot(obj,varargin)
            % This method creates a plot of the given minimum path
            %
            % input:
            % obj                           object of the class solverTravelingSalesman
            % varargin                      additional options of the Matlab plot function
            %
            % output:
            % obj                           object of the class solverTravelingSalesman

            % Compare the relevant timestamps and throw error in case of
            % manipulation
            if ~obj.compareTimestamp
                error('The timestamps of the coordinates of the cities differ. Please, re-apply solve method.')
            end

            % Instantiate a travelingPath-object
            travelingPathObj = travelingPath(obj.handleCitiesObj,obj.minPathCityIndices);

            % Coordinates of the path in correct path order
            closedPathCoordinates = travelingPathObj.getClosedPathCoordinates;

            hold on
            plot(closedPathCoordinates(:,1),closedPathCoordinates(:,2),varargin{:})
            hold off
        end
    end

    methods (Access = protected)
        function obj = addTimestampCoordinatesCities(obj)
            % This method hard-copies the timestamp of the city coordinates and saves it as property
            %
            % input:
            % obj                           object of the class solverTravelingSalesman
            %
            % output:
            % obj                           object of the class solverTravelingSalesman

            obj.timestampCoordinatesCities = obj.handleCitiesObj.timestampCoordinatesCities;
        end
    end

    methods (Abstract)
        % Require that every sub-class has an implementation of the
        % following methods
        solve(obj)
    end
end