classdef SysInfoData < handle
    % properties will be displayed
    properties (SetAccess = 'private')
        % Stored Data
        TimeArray = [];
        UsedCPUArray = [];
        UsedMemoryArray = [];
        
        % General Informations
        UsedCPUUnits = '%';
        UsedMemoryUnits = 'MB';
        NumOfCPU = 0;
        MachineName = '';
        TotalMemory = 0;
        CpuSpeed = '';
    end
    
    % properties will not be displayed
    properties (SetAccess = 'private', GetAccess = 'private')        
        % performance counters
        ProcPerfCounterHandle = [];
        MemPerfCounterHandle = [];
        % data management
        BufferSize = 100;
        NextDataIndex = 1;
    end    
    
    methods
        function obj = SysInfoData() % constructor
            if ~ispc
               errorObj = MException('SysInfoData:NotSupported', 'SysInfoData class is only supported on Windows');
               errorObj.throw();            
            end
            reset(obj);
            [notused,  systemview] = memory;
            obj.TotalMemory = round(systemview.SystemMemory.Available/1024^2);
            
            % Note: this function makes the whole class slow to initialize, 
            %       If not needed this feature feel free to delete it
            obj.CpuSpeed = getCpuSpeed();
            % end of Note
            
            obj.MachineName = char(System.Environment.MachineName);
            obj.NumOfCPU = double(System.Environment.ProcessorCount);
            curProcess = System.Diagnostics.Process.GetCurrentProcess();
            
            % Create performancecounter
            obj.ProcPerfCounterHandle = System.Diagnostics.PerformanceCounter('Process', '% Processor Time', curProcess.ProcessName);            
            obj.MemPerfCounterHandle = System.Diagnostics.PerformanceCounter('Process', 'Working Set', curProcess.ProcessName);            

        end % constructor
        
        function reset(obj)
            % reset the data values
            obj.TimeArray = zeros(obj.BufferSize, 1);
            obj.UsedCPUArray = zeros(obj.BufferSize, 1);
            obj.UsedMemoryArray = zeros(obj.BufferSize, 1);
            
            obj.NextDataIndex = 1;
        end % reset
        
        function measure(obj) 
            % Measure the Time, CPU, Memory
            
            % expand buffer if needed
            if numel(obj.TimeArray) >= obj.NextDataIndex
                % need to expand the buffer
                obj.TimeArray = vertcat(obj.TimeArray, zeros(obj.BufferSize, 1));
                obj.UsedCPUArray = vertcat(obj.UsedCPUArray, zeros(obj.BufferSize, 1));
                obj.UsedMemoryArray = vertcat(obj.UsedMemoryArray, zeros(obj.BufferSize, 1));
                
            end
            
            % Measure new Data
            obj.TimeArray(obj.NextDataIndex) = now;
            obj.UsedCPUArray(obj.NextDataIndex) = obj.ProcPerfCounterHandle.NextValue/obj.NumOfCPU;
            
            % Used Memory            
            obj.UsedMemoryArray(obj.NextDataIndex) = obj.MemPerfCounterHandle.NextValue/1024^2;            
            
            % update pointer            
            obj.NextDataIndex = obj.NextDataIndex + 1;
            
        end % measure
        
        
        function data = get.TimeArray(obj)
            % Get the time array
            data = obj.TimeArray(1:obj.NextDataIndex-1);
        end % get.TimeArray
        
        function data = get.UsedCPUArray(obj)
            % Get the used CPU usage array
            data = obj.UsedCPUArray(1:obj.NextDataIndex-1);
        end % get.UsedCPUArray
        
        function data = get.UsedMemoryArray(obj)
            % Get the used memory array
            data = obj.UsedMemoryArray(1:obj.NextDataIndex-1);
        end % get.UsedMemoryArray        
        
    end % methods    
end % classdef

% util function
function cpuSpeedStr = getCpuSpeed()    
    % get cpu speed in MHz
    cpuSpeedMHz = winqueryreg('HKEY_LOCAL_MACHINE', 'HARDWARE\DESCRIPTION\System\CentralProcessor\0', '~MHz');
    % convert to GHz
    cpuSpeedGHz = double(cpuSpeedMHz)/1000;
    cpuSpeedStr = sprintf('%.2fGHz', cpuSpeedGHz);
end