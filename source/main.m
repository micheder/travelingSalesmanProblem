% This script demonstrates the capabilites of the classes being part of the
% traveling salesman problem solver library

%% clear workspace, close all figures, define filepath for figures
clear all
close all
% Define filePath for figures
filePath = fullfile(pwd,"demoExportedFigures");
% Create directory
mkdir(filePath);

%% initializations
% use cache precomputations for various methods
useCache = false;

% define the randomly generated cities
constructionMethod = 'rand';
numCities = 9;


%% cities class
% instantiate a cities-object
citiesObj = cities(numCities,constructionMethod);

% plot the cities using the related method
f1 = figure;
citiesObj.plot('bo');
xlabel('x');
ylabel('y');
xlim([0,1]);
ylim([-0.1,1]);
axis equal;
box on;
title('Coordinates of randomly generated cities');
legend('Cities','Location','southeast');

% save the figure
figName = ['citiesClass_',num2str(numCities),'_cities.png'];
filePathFig = fullfile(filePath,figName);
saveas(f1,filePathFig);
close(f1);


%% travelingPath class
% create a random path in which order the cities should be traveled
randPathCityIndices = randperm(citiesObj.numCities);

% instantiate a travelingPath-object
travelingPathObj = travelingPath(citiesObj,randPathCityIndices,useCache);

% plot the travelingPath and the cities using the related methods
f2 = figure;
citiesObj.plot('bo');
travelingPathObj.plot('k-');
xlabel('x');
ylabel('y');
xlim([0,1]);
ylim([-0.1,1]);
axis equal;
box on;
title('Randomly generated closed path');
legend('Cities',['Original random path; length = ',num2str(travelingPathObj.pathLength)],'Location','southeast');

% save the figure
figName = ['travelingPathClass_',num2str(numCities),'_cities.png'];
filePathFig = fullfile(filePath,figName);
saveas(f2,filePathFig);
close(f2);


%% solverBruteForce class
% solve the traveling salesman problem using the brute-force approach

% instantiate a solverBruteForce-object
solverBruteForceObj = solverBruteForce(citiesObj,useCache);

% plot the minimum travelingPath (result of solver) and the cities using the related methods
f3 = figure;
citiesObj.plot('bo');
solverBruteForceObj.plot('r--');
xlabel('x');
ylabel('y');
xlim([0,1]);
ylim([-0.1,1]);
axis equal;
box on;
title('Minimum path obtained with brute-force approach');
legend('Cities',['Minimum path; length = ',num2str(solverBruteForceObj.minPathLength)],'Location','southeast');

% save the figure
figName = ['solverBruteForceClass_',num2str(numCities),'_cities.png'];
filePathFig = fullfile(filePath,figName);
saveas(f3,filePathFig);
close(f3);


%% solverSimulatedAnnealing class
% solve the traveling salesman problem using the Simulated Annealing method

% instantiate a solverBruteForce-object
solverSimulatedAnnealing = solverSimulatedAnnealing(citiesObj,useCache);

% plot the minimum travelingPath (result of solver) and the cities using the related methods
f4 = figure;
citiesObj.plot('bo');
solverSimulatedAnnealing.plot('g--');
xlabel('x');
ylabel('y');
xlim([0,1]);
ylim([-0.1,1]);
axis equal;
box on;
title('Minimum path obtained with Simulated Annealing method');
legend('Cities',['Minimum path; length = ',num2str(solverSimulatedAnnealing.minPathLength)],'Location','southeast');

% save the figure
figName = ['solverSimulatedAnnealingClass_',num2str(numCities),'_cities.png'];
filePathFig = fullfile(filePath,figName);
saveas(f4,filePathFig);
close(f4);



