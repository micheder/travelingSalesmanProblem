classdef cities_test < matlab.unittest.TestCase
    properties
        numCities
        constructionMethod
    end

    properties(MethodSetupParameter)
        % Define a cell array with parameters. Each test is run
        % automatically for each cell entry.
        numCitiesArr = num2cell([1:10]);
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
        function checkNewGenerationCoordinates(testCase)
            % This test checks if a new set of coordinates can be generated
            % with the method genCoordinates. Further, it is checked if the
            % timestamp is renewed.
            
            % Instantiate a cities-object
            citiesObj = cities(testCase.numCities,testCase.constructionMethod);

            % Save certain properties before the update
            saveCoordsBefore = citiesObj.coordinatesCities;
            saveTimestampBefore = citiesObj.timestampCoordinatesCities;

            % Update the coordinates
            pause(0.01);
            citiesObj.genCoordinates(testCase.constructionMethod);

            % Save certain properties after the update
            saveCoordsAfter = citiesObj.coordinatesCities;
            saveTimestampAfter = citiesObj.timestampCoordinatesCities;

            % Build check booleans
            checkCoordsDiff = any(saveCoordsBefore ~= saveCoordsAfter,'all');
            checkTimestampDiff = saveTimestampBefore ~= saveTimestampAfter;

            % Verifications
            testCase.verifyEqual(checkCoordsDiff,true,"Check if genCoordinates creates a new set of coordinates.");
            testCase.verifyEqual(checkTimestampDiff,true,"Check if genCoordinates creates a new timestamp.");
        end

        function checkSizeCoordinates(testCase)
            % This test checks if the required number of coordinates were
            % generated

            % Instantiate a cities-object
            citiesObj = cities(testCase.numCities,testCase.constructionMethod);

            % Compare relevant sizes of coordinates
            sizeCoords = size(citiesObj.coordinatesCities);
            checkSize = all(sizeCoords == [testCase.numCities,2]);

            % Verifications
            testCase.verifyEqual(checkSize,true,"Check size of coordinates of cities.");
        end

        function checkErrorMessagesGenCoordinates(testCase)
            % This test checks if errors are thrown, when the input for the
            % genCoordinates method are not as forseen

            % Instantiate a cities-object
            citiesObj = cities(testCase.numCities,testCase.constructionMethod);
            
            % 1. Error: Construction method is manual, no setCoordinates
            % are provided
            isErrorMessageNoSetCoordinates = false;
            try
                citiesObj = citiesObj.genCoordinates('manual');
            catch ME
                if ~isempty(ME.message)
                    isErrorMessageNoSetCoordinates = true;
                end
            end

            % 2. Error: Value for constructionMethod is neither manual nor rand
            isErrorMessageNotValidMethod = false;
            try
                citiesObj = citiesObj.genCoordinates('somethingElse');
            catch ME
                if ~isempty(ME.message)
                    isErrorMessageNotValidMethod = true;
                end
            end

            % 3. Error: Dimension of setCoordinates is not correct
            isErrorMessageSetCoordinates = false;
            try
                citiesObj = citiesObj.genCoordinates('manual',magic(3));
            catch ME
                if ~isempty(ME.message)
                    isErrorMessageSetCoordinates = true;
                end
            end

            % Verifications
            testCase.verifyEqual(isErrorMessageNoSetCoordinates,true,"No setCoordinates are provided.");
            testCase.verifyEqual(isErrorMessageNotValidMethod,true,"ConstructionMethod not valid.");
            testCase.verifyEqual(isErrorMessageSetCoordinates,true,"Dimension of setCoordinates is not correct.");
        end
    end
end