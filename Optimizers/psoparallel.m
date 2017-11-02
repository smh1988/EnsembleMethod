% ------------------------------------------------------
% SwarmOps - Heuristic optimization for Matlab
% Copyright (C) 2003-2010 Magnus Erik Hvass Pedersen.
% Please see the file license.txt for license details.
% SwarmOps on the internet: http://www.Hvass-Labs.org/
% ------------------------------------------------------

% Particle Swarm Optimization (PSO) by Eberhart et al. (1, 2).
% PSO is an optimization method that does not use the
% gradient of the problem. This is a parallelized version of
% a basic 'global-best' variant.
% Literature references:
% (1) J. Kennedy and R. Eberhart. Particle swarm optimization.
%     In Proceedings of IEEE International Conference on Neural
%     Networks, volume IV, pages 1942-1948, Perth, Australia, 1995
% (2) Y. Shi and R.C. Eberhart. A modified particle swarm optimizer.
%     In Proceedings of the IEEE International Conference on
%     Evolutionary Computation, pages 69-73, Anchorage, AK, USA, 1998.
% Parameters:
%     problem; name or handle of optimization problem, e.g. @myproblem.
%     data; data-struct, see e.g. the file myproblemdata.m
%     parameters; behavioural parameters for optimizer,
%                 see file psoparameters.m
% Returns:
%     bestX; best found position in the search-space.
%     bestFitness; fitness of bestX.
%     evaluations; number of fitness evaluations performed.
function [bestX, bestFitness] = psoparallel(problem, data, parameters)

    %added by Mahdi
    global itResults sNum ManipImages tau;
    
    % Copy data contents to local variables for convenience.
    n = data.Dim;
    acceptableFitness = data.AcceptableFitness;
    maxEvaluations = data.MaxEvaluations;
    lowerBound = data.LowerBound;
    upperBound = data.UpperBound;

    % Behavioural parameters for this optimizer.
    s = parameters(1);       % Swarm-size
    omega = parameters(2);   % Inertia weight.
    phiP = parameters(3);    % Particle's best weight.
    phiG = parameters(4);    % Swarm's best weight.

    % Initialize the velocity boundaries.
    range = upperBound-lowerBound;
    lowerVelocity = -range;
    upperVelocity = range;

    % Initialize swarm.
    x = initpopulation(s, n, data.LowerInit, data.UpperInit);     % Particle positions.
    p = x;                                                        % Best-known positions.
    v = initpopulation(s, n, lowerVelocity, upperVelocity);       % Velocities.

    % Compute fitness of initial particle positions. (Parallel)
    fitness = zeros(1, s); % Pre-allocate array for efficiency.
    newFitness = zeros(1, s); % To be used later.
    parfor i=1:s
        %fitness(i) = feval(problem, x(i,:), data);
        fitness(i) = problem( x(i,:),ManipImages, tau); %changed by Mahdi
    end

    % Determine fitness and index of best particle.
    [bestFitness, bestIndex] = min(fitness);

    % Perform optimization iterations until acceptable fitness
    % is achieved or the maximum number of fitness evaluations
    % has been performed.
    iter = 1; % Fitness evaluations above count as iterations.
    maxiter=maxEvaluations;
    while iter <= maxiter% && (bestFitness > acceptableFitness)

        % Update particle velocities and positions. (Non-parallel)
        for i=1:s
            % Pick random weights.
            rP = rand(1, 1);
            rG = rand(1, 1);

            % Update velocity for i'th particle.
            v(i,:) = omega * v(i,:) + ...
                     rP * phiP * (p(i,:) - x(i,:)) + ...
                     rG * phiG * (p(bestIndex,:) - x(i,:));

            % Bound velocity.
            v(i,:) = bound(v(i,:), lowerVelocity, upperVelocity);

            % Update position for i'th particle.
            x(i,:) = x(i,:) + v(i,:);

            % Bound position.
            x(i,:) = bound(x(i,:), lowerBound, upperBound);
        end

        % Compute fitness. (Parallel)
        % Only this fitness evaluation is parallelized
        % which makes synchronization easier.
        parfor i=1:s
            %newFitness(i) = feval(problem, x(i,:), data);
            newFitness(i) = problem( x(i,:),ManipImages, tau); %changed by Mahdi
        end

        % Update best-known positions. (Non-parallel)
        for i=1:s
            if newFitness(i) < fitness(i)
                % Update particle's best-known fitness.
                fitness(i) = newFitness(i);

                % Update particle's best-known position.
                p(i,:) = x(i,:);

                % Update swarm's best-known position.
                if newFitness(i) < bestFitness
                    % Index into the p array.
                    bestIndex = i;
                
                    bestFitness = newFitness(i);
                end
            end
        end

        %itResults(sNum,iter)=bestFitness;
        display(['best=' num2str( bestFitness)]);
        
        % Increment counter.
        iter = iter + 1;
    end

    % Return best found solution, fitness already set.
    bestX = p(bestIndex,:);
end

% ------------------------------------------------------

%% these functions moved here by Mahdi
% ------------------------------------------------------
% SwarmOps - Heuristic optimization for Matlab
% Copyright (C) 2003-2010 Magnus Erik Hvass Pedersen.
% Please see the file license.txt for license details.
% SwarmOps on the internet: http://www.Hvass-Labs.org/
% ------------------------------------------------------

% Initialize a population of agents with uniformly random
% positions.
% Parameters:
%     numAgents; number of agents in population.
%     dim; dimensionality of search-space.
%     lower; lower boundary of search-space.
%     upper; upper boundary of search-space.
% Returns:
%     x; random position.
function x = initpopulation(numagents, dim, lower, upper)
    % Preallocate array for efficiency.
    x = zeros(numagents,dim);

    for i=1:numagents
        x(i,:) = initagent(dim, lower, upper);
    end
end

% ------------------------------------------------------

% ------------------------------------------------------
% SwarmOps - Heuristic optimization for Matlab
% Copyright (C) 2003-2010 Magnus Erik Hvass Pedersen.
% Please see the file license.txt for license details.
% SwarmOps on the internet: http://www.Hvass-Labs.org/
% ------------------------------------------------------

% Initialize an agent with a uniformly random position.
% Parameters:
%     dim; dimensionality of search-space.
%     lower; lower boundary of search-space.
%     upper; upper boundary of search-space.
% Returns:
%     x; random position.
function x = initagent(dim, lower, upper)
    x = rand(1, dim).*(upper-lower) + lower;
end

% ------------------------------------------------------

% ------------------------------------------------------
% SwarmOps - Heuristic optimization for Matlab
% Copyright (C) 2003-2010 Magnus Erik Hvass Pedersen.
% Please see the file license.txt for license details.
% SwarmOps on the internet: http://www.Hvass-Labs.org/
% ------------------------------------------------------

% Enforce boundaries:
%     if x<lower then y=lower
%     elseif x>upper then y=upper
%     else y=x
% The implementation below works for arrays as well.
% Parameters:
%     x; position to be bounded.
%     lower; lower boundary.
%     upper; upper boundary;
% Returns:
%     y; bounded position.
function y = bound(x, lower, upper)
    y = min(upper, max(lower, x));
end

% ------------------------------------------------------