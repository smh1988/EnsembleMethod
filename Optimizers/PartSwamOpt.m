function best_variables = PartSwamOpt(fun, funCInEq, funCEq, lb, ub, penalty, popsize, maxiter, maxrun)
% This minimizes the function fun, subject to the inequality constraints
% funCInEq and Equality constrants funCEq within the hyperbox between lb
% and ub
% fun      = function handle for the function to be minimized
% funCInEq = function handle for the inequality condition (set to
%            empty matrix when there is no inequality condition)
% funCEq   = function handle for the equality condition (set to
%            empty matrix when there is no equality condition)
% lb       = vector of lower bounds
% ub       = vector of upper bounds
% penalty  = scale violation of constrain conditions (usually between 10
%            and 100)
% popsize  = population size (usually 30 to 50)
% maxiter  = maximum iteration(less than 500)
% maxrun   = maximum number of runs( 10 or less)

%%  %%%%%%%%%%%%%%%% Examples %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1.
% Roosenbrook = @(x) (1 - x(1))^2 + 100*(x(2) - x(1)^2)^2;
% PartSwamOpt(Roosenbrook, [], [], [-2;-1], [2;3], 0, 30, 500, 10);

% 2.
% Adjiman = @(x) cos(x(1))*sin(x(2)) – x(1)/(x(2)^2 + 1);
% PartSwamOpt(Adjiman, [], [], [-1;-1], [2;1], 0, 30, 500, 10);

% 3.
% Beale = @(x) (1.5-x(1) + x(1)*x(2))^2 + (2.25-x(1) + x(1)*x(2)^2)^2 + (2.625-x(1) + x(1)*x(2)^3)^2;
% PartSwamOpt(Beale, [], [], [-1;-1], [2;1], 0, 30, 500, 10);

%% %%%%%%%%%%%%%%%%%%%%%%%%% Function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global Fun FunCInEq FunCEq Penalty itResults sNum
Fun      = fun;
FunCInEq = funCInEq;
FunCEq   = funCEq;
Lb       = lb;
Ub       = ub;
Penalty  = penalty;

%close all
% pso parameters values
m    = numel(lb); % Number of variables
n    = popsize; % Population size
wmax = 0.9; % Maximum inertia weight
wmin = 0.4; % Minimum inertia weight
c1   = 2; % Acceleration factor
c2   = 2; % Acceleration factor
tol  = 1e-12;
fmingain = 1;
fff    = zeros(1, maxrun);
rgbest = zeros(m, maxrun);
ffmin  = zeros(maxiter, maxrun);
ffite  = zeros(maxrun,1);
for run = 1:maxrun
 %% %%%%%%%%%%%%%%%%%%%%%  Initialization  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    x0 = zeros(m,n);
    for i = 1:n
        x0(:, i) = Lb + rand(m, 1).*(Ub-Lb);
    end
    x = x0; % initial population
    v = 0.1 * x0; % initial velocity
    f0 = zeros(1, n);
    for i = 1:n
        f0(i) = Objfun(x0(:, i));
    end
    [fmin0,index0] = min(f0);
    pbest = x0; % initial population best
    gbest = x0(:, index0); % initial global best
 % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 %% %%%%%%%%%%%%%%%%%%%%%%%% PSO Algorithm  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    iter = 1;
    tolerance = 1;
    while iter <= maxiter && tolerance > tol
        % Quadratic update of inertial weight
        w =wmax - (wmax - wmin)*(iter/maxiter)^2;
        f = zeros(n,1);
        for i=1:n
            % Velocity updates
            v(:, i) = w * v(:, i) + c1 * rand(m, 1).*(pbest(:, i) - x(:, i))...
                                   +c2 * rand(m, 1).*(gbest - x(:, i));

            % Position update
            x(:, i) = x(:, i) + v(:, i);

            % Reversing velocities for boundary violations
            x(:, i) = min(max(x(:, i),Lb),Ub);
            id = find(x(:, i) < Lb); 
            v(id, i) = -v(id, i);
            id = find(x(:, i) > Ub); 
            v(id, i) = -v(id, i);

            % Evaluating fitness
            f(i) = Objfun(x(:, i));
        end
        % updating pbest and fitness
        for i = 1:n
            if f(i) < f0(i)
                pbest(:, i) = x(:, i);
                f0(i) = f(i);
            end
        end
        [fmin,index] = min(f0); % finding out the best particle
        ffmin(iter,run) = fmin; % storing best fitness
        ffite(run) = iter; % storing iteration count
        % updating gbest and best fitness
        if fmin < fmin0
            gbest = pbest(:, index);
            fmin0 = fmin;
        end
        % calculating tolerance
        if iter > maxiter/10;
            tolerance = abs(ffmin(iter - maxiter/10, run) - fmin0);
        end
        % displaying iterative results
        if iter == 1
            fprintf('Iteration Best particle Objective fun\n');
        end
        fprintf('%8g\t %8g\t %8.4f\n',iter,index,fmin0);
        %display(gbest');
        itResults(sNum,run,iter)=fmin0;
        iter = iter + 1;
    end
 % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 %% %%%%%%%%%%%%%%%%% Extracting run result %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fvalue = fun(gbest);
    fff(run) = fvalue;
    rgbest(:, run) = gbest;

    Lb = max(lb, gbest - (gbest - Lb) / 1.5);
    Ub = min(ub, gbest + (Ub - gbest) / 1.5);

    if run>1
     fmingain = fff(run) - fff(run - 1);
     disp(['fmingain = ', num2str(fmingain)])
    end

    if abs(fmingain) < tol
     break;
    end
end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% %%%%%%%%%%%%%%%%%%% Extreact Final Solution %%%%%%%%%%%%%%%%%%%%%%%%%%%%
[~,bestrun] = min(fff);
best_variables = rgbest(:, bestrun);
bestfun = fun(best_variables);
% fprintf('*********************************************************');

%% PSO convergence characteristic

plot(ffmin(1:ffite(bestrun),bestrun),'-k','linewidth',2); grid on
xlabel('$ Iteration $', 'fontsize', 20, 'Interpreter', 'latex');
ylabel('$ Fitness~function~value $', 'fontsize', 20, 'Interpreter', 'latex');
title('$ PSO~convergence~characteristic $', 'fontsize', 20, 'Interpreter', 'latex')
saveas(gcf,['synth number ' num2str(sNum) '-PSO Convergence.png'])
if (numel(Lb) == 2)
    [X,Y] = meshgrid(linspace(lb(1),ub(1),50),linspace(lb(2),ub(2),50));
    F = zeros(size(X)); C = F;
    for i = 1:50
        for j = 1:50
            F(i,j) = fun([X(i,j),Y(i,j)]);
            C(i,j) = Objfun([X(i,j),Y(i,j)]);
        end
    end
    figure
    surfhandle = surf(X,Y,F,C); set(surfhandle, 'edgealpha',0.2, 'edgecolor','w'); 
    view(60,50); hold on; grid off
    colormap jet
    caxis([min(min(C)) min(min(C)) + 0.05 * (max(max(C)) - min(min(C)))])
    text(best_variables(1),best_variables(2),bestfun + 0.1 * (max(max(F)) - min(min(F))),....
        '<--min point','HorizontalAlignment','Left','Rotatio',90,'fontsize', 15);
    plot3(best_variables(1),best_variables(2),bestfun, 'ok', 'markersize',10, 'MarkerFaceColor','k');
    axis([lb(1) ub(1) lb(2) ub(2) min(min(F)) max(max(F))])
end
%saveas(gcf,'figure2.png')
function f = Objfun(x)
global Fun FunCInEq FunCEq Penalty
f = Fun(x);
if isa(FunCInEq,'function_handle')
    c0 = FunCInEq(x);
    f = f + Penalty*(sum((c0>0).*c0));
end
if isa(FunCEq,'function_handle')
    d0 = FunCEq(x);
    f = f + Penalty*(sum(abs(d0)));
end


