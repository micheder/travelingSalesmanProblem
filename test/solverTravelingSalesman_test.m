classdef solverTravelingSalesman_test < matlab.unittest.TestCase

    properties
        numCities
        constructionMethod
        citiesObj
        minPathLength
        filePath
    end

    properties(MethodSetupParameter)
        % Define a cell array with parameters. Each test is run
        % automatically for each cell entry.
        numCitiesArr = num2cell([2:9]);
    end

    methods (TestMethodSetup)
        function setupCitiesObjAndTravelPath(testCase,numCitiesArr)
            % Save the number of cities for each test case
            testCase.numCities = numCitiesArr;

            % Set the standard constructionMethod to 'rand' for all test
            % cases
            testCase.constructionMethod = 'manual';

            % Generate cities that lie on a circle with origin [0.5,0.5]
            % and radius 0.25
            setCoordinates = nan(testCase.numCities,2);
            for i = 1:testCase.numCities
                setCoordinates(i,1) = 0.5 + 0.25 * cos(2 * pi / testCase.numCities * i);
                setCoordinates(i,2) = 0.5 + 0.25 * sin(2 * pi / testCase.numCities * i);
            end

            % Compute the minimum path length of a rotationally symmetric path via instantiating a travelingPath-object
            citiesObjTemp = cities(testCase.numCities,testCase.constructionMethod,setCoordinates);
            travelingPathObjTemp = travelingPath(citiesObjTemp,[1:citiesObjTemp.numCities]);
            testCase.minPathLength = travelingPathObjTemp.pathLength; %solverTravelingSalesman_test.computeMinPathLengthRotSym(setCoordinates);

            % Randomly shuffle setCoordinates in order to destroy the path
            % information of the cities
            randPathCityIndices = randperm(testCase.numCities);
            setCoordinates = setCoordinates(randPathCityIndices,:);

            % Instantiate cities object
            testCase.citiesObj = cities(testCase.numCities,testCase.constructionMethod,setCoordinates);

            % Define filePath for figures
            testCase.filePath = fullfile(pwd,"test","exportedFigures");
        end
    end

    methods (Test)
        function testSolveBruteForce(testCase)
            % Instantiate a travelingPath-object using the randomly ordered cities
            travelingPathObj = travelingPath(testCase.citiesObj,[1:testCase.numCities]);

            % Solve the traveling salesman problem with the brute-fore approach
            solverBruteForceObj = solverBruteForce(testCase.citiesObj);
            
            % Create a figure demonstrating the solution
            fig = figure;
            testCase.citiesObj.plot('bo');
            travelingPathObj.plot('k:');
            solverBruteForceObj.plot('r--');
            xlabel('x');
            ylabel('y');
            axis equal;
            box on;
            xlim([0,1]);
            ylim([0,1]);
            title(['Minimum path obtained with brute-force approach for ',num2str(testCase.numCities),' cities']);
            legend('Cities',['Original random path; length = ',num2str(travelingPathObj.pathLength)],['Minimum path; length = ',num2str(solverBruteForceObj.minPathLength)]);

            % Export the figure as .png

            figName = ['solveBruteForce_',num2str(testCase.numCities),'_cities.png'];
            filePathFig = fullfile(testCase.filePath,figName);
            saveas(fig,filePathFig);
            close(fig);

            % Comparison
            checkMinPathLength = abs(solverBruteForceObj.minPathLength - testCase.minPathLength) < 1E-9;

            % Verification
            testCase.verifyEqual(checkMinPathLength,true,"Check that minimum path length was computed correctly.");   
        end

        function testSolveSimulatedAnnealing(testCase)
            % Instantiate a travelingPath-object using the randomly ordered cities
            travelingPathObj = travelingPath(testCase.citiesObj,[1:testCase.numCities]);

            % Solve the traveling salesman problem using Simulated Annealing
            solverSimulatedAnnealingObj = solverSimulatedAnnealing(testCase.citiesObj);

            fig = figure;
            testCase.citiesObj.plot('bo');
            travelingPathObj.plot('k:');
            solverSimulatedAnnealingObj.plot('r--');
            xlabel('x');
            ylabel('y');
            axis equal;
            box on;
            xlim([0,1]);
            ylim([0,1]);
            title(['Minimum path obtained using Simulated Annealing for ',num2str(testCase.numCities),' cities']);
            legend('Cities',['Original random path; length = ',num2str(travelingPathObj.pathLength)],['Minimum path; length = ',num2str(solverSimulatedAnnealingObj.minPathLength)]);

            figName = ['solveSimulatedAnnealing_',num2str(testCase.numCities),'_cities.png'];
            filePathFig = fullfile(testCase.filePath,figName);
            saveas(fig,filePathFig);
            close(fig);

            % Comparison
            checkMinPathLength = abs(solverSimulatedAnnealingObj.minPathLength - testCase.minPathLength) < 1E-9;

            % Verification
            testCase.verifyEqual(checkMinPathLength,true,"Check that minimum path length was computed correctly.");   
        end
    end
end