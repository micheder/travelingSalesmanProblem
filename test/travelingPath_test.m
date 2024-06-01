classdef travelingPath_test < matlab.unittest.TestCase

    properties
        numCities
        constructionMethod
    end

    properties(MethodSetupParameter)
        % Define a cell array with parameters. Each test is run
        % automatically for each cell entry.
        numCitiesArr = num2cell([2:10]);
    end

    methods (TestMethodSetup)
        function setupCitiesObj(testCase,numCitiesArr)
            % Save the number of cities for each test case
            testCase.numCities = numCitiesArr;

            % Set the standard constructionMethod to 'rand' for all test
            % cases
            testCase.constructionMethod = 'rand';

            % Set the seed number for the Matlab random number generator
            seed = 42; % any given integer
            rng(seed);
        end
    end

    methods (Test)
        function checkSizePathCityIndices(testCase)
            % This test checks if the required number of indices is eqal to
            % the input argument of the constructor

            % Instantiate a cities-object
            citiesObj = cities(testCase.numCities,testCase.constructionMethod);

            % Create a random path in which order the cities should be traveled
            randPathCityIndices = randperm(citiesObj.numCities);

            % Instantiate a travelingPath-object
            travelingPathObj = travelingPath(citiesObj,randPathCityIndices);

            % Compare relevant sizes of coordinates
            checkSize = all(size(travelingPathObj.pathCityIndices) == size(randPathCityIndices));

            % Verifications
            testCase.verifyEqual(checkSize,true,"Check size of pathCityIndices.");
        end

        function checkComputePathLengthSquare(testCase)
            % This test checks if the computed path length of a square path is correct

            % define manually generated cities
            constructionMethodManual = 'manual';
            numCitiesManual = 4;
            setCoordinates = [0.25,0.25;...
                              0.25,0.75;...
                              0.75,0.75;...
                              0.75,0.25];

            % Instantiate a manually defined cities-object
            citiesObjMan = cities(numCitiesManual,constructionMethodManual,setCoordinates);

            % Instantiate a travelingPath-object
            travelingPathObj = travelingPath(citiesObjMan,[1:numCitiesManual]);

            % Comparison
            checkPathLength = travelingPathObj.pathLength == 2;

            % Verification
            testCase.verifyEqual(checkPathLength,true,"Check that path length is correct.");                       
        end

        function checkErrorMessages(testCase)
            % This test checks if errors are thrown, when the constructor
            % inputs are not as forseen.

            % 1. Error: The number of cities is smaller than the provided indices vector
            isErrorMessageWrongIndicesSize = false;
            try
                % Instantiate a cities-object
                citiesObj1 = cities(testCase.numCities,testCase.constructionMethod);

                % Create a random path in which order the cities should be traveled
                randPathCityIndices = randperm(citiesObj1.numCities + 1);

                % Instantiate a travelingPath-object
                travelingPathObj1 = travelingPath(citiesObj1,randPathCityIndices);
            catch ME
                if ~isempty(ME.message)
                    isErrorMessageWrongIndicesSize = true;
                end
            end

            % 2. Error: The number of cities is smaller than two
            isErrorMessageOneCity = false;
            try
                % Instantiate a cities-object
                citiesObj2 = cities(1,testCase.constructionMethod);

                % Create a random path in which order the cities should be traveled
                randPathCityIndices = randperm(citiesObj2.numCities);

                % Instantiate a travelingPath-object
                travelingPathObj2 = travelingPath(citiesObj2,randPathCityIndices);
            catch ME
                if ~isempty(ME.message)
                    isErrorMessageOneCity = true;
                end
            end

            % Verification
            testCase.verifyEqual(isErrorMessageWrongIndicesSize,true,"Size of pathCityIndices is not correct.");
            testCase.verifyEqual(isErrorMessageOneCity,true,"Only one city.");
        end
    end
end