classdef cities < handle
    % This class is meant for creating the coordinates of cities and
    % storing the coordinate values and the number of cities. In addition
    % a matrix containing the distances between all tuples of cities can pe
    % pre-computed and stored as cache for further usage.

    % The class is inherited from the handle class.

    properties (GetAccess = public, SetAccess = private)
        numCities                       % integer: the number of cities
        coordinatesCities               % double (numCities x 2): the cartesian coordinates (x,y) of the cities
        timestampCoordinatesCities      % double: timestamp when the coordinates of the cities were generated
        cacheDistTwoCities              % double (numCities x numCities): pre-computed cache giving the distances between tuples of cites
        isComputedCache = false;        % boolean: indicator if cacheDistTwoCities is already computed
    end

    methods
        function obj = cities(numberCities,constructionMethod,varargin)       
            % Constructor:
            % This method creates an instance of the class 'cities'.
            %
            % input:
            % numberCities                  integer: the number of cities
            % constructionMethod            string: 'manual' or 'rand', the construction method for the coordinates
            % setCoordinates                double (numCities x 2, optional): the cartesian coordinates (x,y) of the cities to be set
            % computeCache                  boolean (optional): flag if cache containing the distances between tuples of cities
            %                                                   is precomputed during construction of object
            %
            % output:
            % obj                           object of the class cities

            % handling of optional input argument; 
            if nargin < 3 || isempty(varargin{1})
                setCoordinates = nan; 
            else 
                setCoordinates = varargin{1}; 
            end
            % set the default value of computeCache to false
            if nargin < 4 || isempty(varargin{2})
                computeCache = false; 
            else 
                computeCache = varargin{2}; 
            end

            % the number of cities to be constructed
            obj.numCities = numberCities;

            % generate the coordinates of the cities
            obj.genCoordinates(constructionMethod,setCoordinates);

            % otionally compute the cache array containing the distances in between
            % all pairs of two cities
            if computeCache
                obj.compCacheDistTwoCities;
            end
        end

        function obj = genCoordinates(obj,constructionMethod,varargin)
            % This method generates the coordinates of the cities.
            %
            % input:
            % obj                           object of the class cities
            % constructionMethod            string: 'manual' or 'rand', the construction method for the coordinates
            % setCoordinates                double (numCities x 2, optional): the cartesian coordinates (x,y) of the cities to be set
            %
            % output:
            % obj                           object of the class cities

            % check for validity of the construction method
            isConstructionMethodValid = ismember(constructionMethod,{'manual','rand'});
            if ~isConstructionMethodValid
                error('The given value for constructionMethod is not valid. Please use either manual or rand.')
            end

            % check if setCoordinates is valid when construction method is
            % manual
            if strcmp(constructionMethod,'manual')
                if nargin < 3 || isempty(varargin{1})
                    error('If the construction method is set to be manual, setCoordinates must be provided or must not be empty.')
                else
                    setCoordinates = varargin{1};
                end
            end

            % Select if the cities should either be generated manually or randomly
            switch constructionMethod
                case 'manual'
                    % Check the size of the coordinates
                    if ~all(size(setCoordinates) == [obj.numCities,2])
                        error('The size of setCoordinates must be numCities x 2.')
                    end
                    obj.coordinatesCities = setCoordinates;
                case 'rand'
                    obj.coordinatesCities = cities.genRandCoordinates(obj.numCities);
            end

            % set a timestamp when the city coordinates were generated
            obj.timestampCoordinatesCities = now;
        end

        function obj = plot(obj,varargin)
            % This method creates a 2d scatter plot of the cartestion coordinates of the cities.
            %
            % input:
            % obj                           object of the class cities
            % varargin                      additional options of the Matlab scatter function
            %
            % output:
            % obj                           object of the class cities

            hold on
                scatter(obj.coordinatesCities(:,1),obj.coordinatesCities(:,2),varargin{:});
            hold off
        end

        function [distTwoCities] = compDistTwoCities(obj,indexCityI,indexCityJ)
            % This method computes the distance between two cities given by their indices.
            %
            % input:
            % obj                           object of the class cities
            % indexCityI                    integer: index of city I
            % indexCityJ                    integer: index of city J
            %
            % output:
            % distTwoCities                 double: distance between the two cities defined by indices I and J

            distTwoCities = norm(obj.coordinatesCities(indexCityI,:) - obj.coordinatesCities(indexCityJ,:));
        end

        function obj = compCacheDistTwoCities(obj)
            % This method computes the cache for the distances given by all
            % permutations of two cities
            %
            % input:
            % obj                           object of the class cities
            %
            % output:
            % obj                           object of the class cities

            % Infoprint
            disp('Info: the cache array cacheDistTwoCities is computed.');

            % Initialize a numCities x numCities array wit zero-entries
            obj.cacheDistTwoCities = zeros(obj.numCities);

            % Compute all entries (distance bewteen two cities) of the cache
            % array. The cache-array is symmetric.
            for i = 1:obj.numCities
                for j = (i+1):obj.numCities
                    obj.cacheDistTwoCities(i,j) = obj.compDistTwoCities(i,j);
                    obj.cacheDistTwoCities(j,i) = obj.cacheDistTwoCities(i,j);
                end
            end

            % Indicate that chache has been computed
            obj.isComputedCache = true;
        end
    end

    % Helper methods for this class
    methods (Access = private, Static = true)
        function [coordinatesArr] = genRandCoordinates(numCoordinates)
            % This method creates an array of randomly generated
            % coordinates
            %
            % input:
            % numCoordinates                integer: number of coordinate-pairs to be generated
            %
            % output:
            % coordinatesArr                double (numCoordinates x 2): randomly generated cartesian coordinates (x,y)
            %                                                            with a uniform distribution in the interval (0,1)

            % Create a N x 2 array with random coordinates
            coordinatesArr = rand(numCoordinates,2);
        end
    end
end