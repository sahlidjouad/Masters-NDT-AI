% %Define the training data. The first two columns of data are the inputs to the ANFIS model, n
% %and a delayed version of n
% %The final column of data is the measured signal, m.
% 
% delayed_n   1 = [0; n1(1:length(n1)-1)];
% data = [delayed_n1 n1 m];
% 
% %Generate the initial FIS object. By default, the grid partitioning algorithm uses two membership functions for each input variable, which produces four fuzzy rules for learning.
% genOpt = genfisOptions('GridPartition');
% inFIS = genfis(data(:,1:end-1),data(:,end),genOpt);
% 
% %Tune the FIS using the anfis command with an initial training step size of 0.2.
% trainOpt = anfisOptions('InitialFIS',inFIS,'InitialStepSize',0.2);
% outFIS = anfis(data,trainOpt);
% 


clear all ;close all; clc; i=0; 
for f=0:1 % f = 0, 1 
    for k=1:90% k = 1, 2 valeurs pour notre travail 1:90
        ima= sprintf('%d_image_%d.jpg',f,k); %d prend la valeur de f et k 
        im=imread(ima); % importe l'image 
        im=im2double(im); % transforme en format Double ex = 3.14 
        %imagesc(im); % visualise l'image figure; % permet de garder l'image %
        i=i+1; %
        cell_size = 64;
        %features_sift = detectSURFFeatures(im);
        features_LBP(i,:) = extractLBPFeatures(im,'CellSize',[cell_size,cell_size]); 
       %save('features'); 
       
       
    end
end
features_LBP=double(features_LBP);


i=0;
for f=0:1 % f = 0, 1 
    for k=1:90% k = 1, 2 valeurs pour notre travail 1:90
        ima= sprintf('%d_image_%d.jpg',f,k); %d prend la valeur de f et k 
        im=imread(ima); % importe l'image 
        im=im2double(im); % transforme en format Double ex = 3.14 
        %imagesc(im); % visualise l'image figure; % permet de garder l'image %
        i=i+1; %
        cell_size = 4;
        %features_sift = detectSURFFeatures(im);
        [features_HOG,visualization]=extractHOGFeatures(im,'CellSize',[cell_size,cell_size]);
        %features_HOG(i,:) = extractHOGFeatures(im,'CellSize',[cell_size,cell_size]); 
       %save('features'); 
       
       
    end
end

subplot(1,2,1);
imshow(ima);
subplot(1,2,2);
plot(visualization);
features_HOG=double(features_HOG);




%Stuff for data Augmentation HERE
% augmenter = imageDataAugmenter('RandXReflection',true,'RandRotation',[0 90],'RandYReflection',true,'RandYReflection',true)


%Creation du fichier data contenant les descripteurs
%data = load('Nom du fichier sous format mat.mat'); %exportation du wrokspace mat lab sous forme de mat




%% Create Time-Series Data

data = load('hog cellsize 32 (324cols)+lbp_data.mat');

% TrainInputs_LBP = data.features_LBP(1:170,:);
% TrainTargets_LBP = data.features_LBP(:,end); %je ne sais pas encore pourquoi le tragetset existe
% 
% TestInputs_LBP = data.features_LBP(171:180,:);
% TestTargets_LBP = data.features_LBP(:,end); %je ne sais pas encore pourquoi le tragetset existe
train_number=170;

TrainInputs_LBP = data.Combined(1:train_number,:);
TrainTargets_LBP = data.Combined(1:train_number,:); %j'ai trouvé pourquoi la fonction FCM GENFIS3() a besoin du target data dans les inputs params

TestInputs_LBP = data.Combined(train_number+1:end,:);
TestTargets_LBP = data.Combined(train_number+1:end,:); %parcontre le nombre de data targets est a investiguer



% TrainInputs_HOG = data.features_HOG(1:170,:);
% TrainTargets_HOG = data.features_HOG(:,end); %c'est l'output data ajoute une collone à la fin
% 
% TestInputs_HOG = data.features_HOG(171:180,:);
% TestTargets_HOG = data.features_HOG(:,end);

TrainInputs=TrainInputs_LBP;
TestInputs=TestInputs_LBP;
TrainTargets=TrainInputs_LBP;
TestTargets=TestInputs_LBP;


%% Setting the Parameters of FIS Generation Methods

% switch ANSWER
%    case Option{1}
%        Prompt={'Number of MFs','Input MF Type:','Output MF Type:'};
%       Title='Enter genfis1 parameters';
%        DefaultValues={'5', 'gaussmf', 'linear'};
%         
%        PARAMS=inputdlg(Prompt,Title,1,DefaultValues);
%        pause(0.01);
% 
%        nMFs=str2num(PARAMS{1});	%#ok
%        InputMF=PARAMS{2};
%         OutputMF=PARAMS{3};
%         
%        fis=genfis1([TrainInputs TrainTargets],nMFs,InputMF,OutputMF);
% 
%     case Option{2}
       Prompt={'Influence Radius:'};
       Title='Enter genfis2 parameters';
       DefaultValues={'0.3'};
        
       PARAMS=inputdlg(Prompt,Title,1,DefaultValues);
       pause(0.01);

       Radius=str2num(PARAMS{1});	%#ok
        
       fis=genfis2(TrainInputs,TrainTargets,Radius);
%         
%    case Option{3}
%         Prompt={'Number of Clusters:',...
%                 'Partition Matrix Exponent:',...
%                 'Maximum Number of Iterations:',...
%                 'Minimum Improvemnet:'};
%         Title='Enter genfis3 parameters';
%         DefaultValues={'15', '2', '200', '1e-5'};
%         
%         PARAMS=inputdlg(Prompt,Title,1,DefaultValues);
%         pause(0.01);
% 
%         nCluster=str2num(PARAMS{1});        %#ok
%         Exponent=str2num(PARAMS{2});        %#ok
%         MaxIt=str2num(PARAMS{3});           %#ok
%         MinImprovment=str2num(PARAMS{4});	%#ok
%         DisplayInfo=1;
%         FCMOptions=[Exponent MaxIt MinImprovment DisplayInfo];
%         
%         fis=genfis3(TrainInputs,TrainTargets,'sugeno',nCluster,FCMOptions);
%end
% 
% 

%% Training ANFIS Structure

%prev_accuracy=0;
%for x=1 : 5 
    Prompt={'Maximum Number of Epochs:',...
            'Error Goal:',...
            'Initial Step Size:',...
           'Step Size Decrease Rate:',...
         'Step Size Increase Rate:'};
    Title='Enter genfis3 parameters';
    DefaultValues={'10', '0', '0.01', '0.9', '1.1'};

    PARAMS=inputdlg(Prompt,Title,1,DefaultValues);
    pause(0.01);

    MaxEpoch=str2num(PARAMS{1});                %#ok
    ErrorGoal=str2num(PARAMS{2});               %#ok
    InitialStepSize=str2num(PARAMS{3});         %#ok
    StepSizeDecreaseRate=str2num(PARAMS{4});    %#ok
    StepSizeIncreaseRate=str2num(PARAMS{5});    %#ok
    TrainOptions=[MaxEpoch ...
                  ErrorGoal ...
                  InitialStepSize ...
                  StepSizeDecreaseRate ...
                  StepSizeIncreaseRate];

    DisplayInfo=true;
    DisplayError=true;
    DisplayStepSize=true;
    DisplayFinalResult=true;
    DisplayOptions=[DisplayInfo ...
                    DisplayError ...
                    DisplayStepSize ...
                    DisplayFinalResult];
    
    OptimizationMethod=1;
% 0: Backpropagation
% 1: Hybrid
            
    [fis,trainError,stepSize,chkFIS,chkError]=anfis([TrainInputs TrainTargets],fis,TrainOptions,DisplayOptions,[],OptimizationMethod);
    
    

%% Apply ANFIS to Data

    TrainOutputs=evalfis(TrainInputs,fis);
    TestOutputs=evalfis(TestInputs,fis);








