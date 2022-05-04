classdef code_exported < matlab.apps.AppBase

    % Properties that corresponMEE428Project_exportedd to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        SendButton                    matlab.ui.control.Button
        ConnectedLamp                 matlab.ui.control.Lamp
        ConnectedLampLabel            matlab.ui.control.Label
        SystemResponseEditField       matlab.ui.control.NumericEditField
        SystemResponseEditFieldLabel  matlab.ui.control.Label
        ReferenceInputEditField       matlab.ui.control.NumericEditField
        ReferenceInputEditFieldLabel  matlab.ui.control.Label
        AnalogVoltageEditField        matlab.ui.control.NumericEditField
        AnalogVoltageEditFieldLabel   matlab.ui.control.Label
        SettheValuesandSendViaSerialLabel  matlab.ui.control.Label
        DEditField                    matlab.ui.control.NumericEditField
        DEditFieldLabel               matlab.ui.control.Label
        IEditField                    matlab.ui.control.NumericEditField
        IEditFieldLabel               matlab.ui.control.Label
        PEditField                    matlab.ui.control.NumericEditField
        PEditFieldLabel               matlab.ui.control.Label
        disconnectButton              matlab.ui.control.Button
        connectButton                 matlab.ui.control.Button
        UIAxes                        matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
        s               % Serial
        SystemResponseY % System response y variable for plot
        ctr             % Counter to store the elements in arrays for plot
        PIDR            % Array for storing PID and Reference Input Values
    end
     
    methods (Access = private)
        function ReadInputDataOverSerial(app, hObject, eventdata, handles)
            
            %Read
            Values=fread(app.s,[1,app.s.BytesAvailable],'char');
            
           if(~isempty(Values))
            
            %Extract
            analogVoltageValue= Values(1);
%             referenceInput    = Values(3);
            systemResponse    = Values(5);
            
            %Store
            app.SystemResponseY{app.ctr} = systemResponse;
            app.ctr = app.ctr + 1;
            
            %Display in GUI
            app.AnalogVoltageEditField.Value  = analogVoltageValue;
%             app.ReferenceInputEditField.Value = referenceInput;
            app.SystemResponseEditField.Value = systemResponse;            
           end

            %Plot
            x = 1:size(app.SystemResponseY,2);
            y = zeros(1,size(app.SystemResponseY,2));
            for i=1:size(y,2)
                y(i) = app.SystemResponseY{i};
            end
            
            if (mod(app.ctr,5)==0)
            plot(app.UIAxes,x,y,'LineWidth',2);
            end

        end
        
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.SystemResponseY = cell(1,1);  %Initialize the variable
            app.ctr = 1; %Set the counter to 1
            app.ConnectedLamp.Color = 'red';
            app.PIDR = [0 0 0 0];
%             newobjs=instrfind
%             gl=newobjs(7)
%             fclose(newobjs)
        end

        % Button pushed function: connectButton
        function connectButtonPushed(app, event)

            app.s=serial('COM7','BaudRate',9600);
            app.s.BytesAvailableFcn={@app.ReadInputDataOverSerial};
            app.s.BytesAvailableFcnCount = 7;
            app.s.BytesAvailableFcnMode='byte';
            fopen(app.s);
            app.ConnectedLamp.Color = 'green';
        end

        % Button pushed function: disconnectButton
        function disconnectButtonPushed(app, event)
            fclose(app.s);
            app.ConnectedLamp.Color = 'red';
        end

        % Value changed function: PEditField
        function PEditFieldValueChanged(app, event)
            value = app.PEditField.Value;
            app.PIDR(1) = value;
        end

        % Value changed function: IEditField
        function IEditFieldValueChanged(app, event)
            value = app.IEditField.Value;
            app.PIDR(2) = value;
        end

        % Value changed function: DEditField
        function DEditFieldValueChanged(app, event)
            value = app.DEditField.Value;
            app.PIDR(3) = value;
        end

        % Value changed function: ReferenceInputEditField
        function ReferenceInputEditFieldValueChanged(app, event)
            value = app.ReferenceInputEditField.Value;
            app.PIDR(4) = value;
        end

        % Button pushed function: SendButton
        function SendButtonPushed(app, event)
        fwrite(app.s,app.PIDR)
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 900 549];
            app.UIFigure.Name = 'MATLAB App';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'System Response')
            xlabel(app.UIAxes, 'step')
            ylabel(app.UIAxes, 'Motor Angle')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.YTick = [0 120 240 360];
            app.UIAxes.XGrid = 'on';
            app.UIAxes.YGrid = 'on';
            app.UIAxes.Position = [285 258 568 274];

            % Create connectButton
            app.connectButton = uibutton(app.UIFigure, 'push');
            app.connectButton.ButtonPushedFcn = createCallbackFcn(app, @connectButtonPushed, true);
            app.connectButton.Tag = 'connectButton';
            app.connectButton.BackgroundColor = [0.917647058823529 0.894117647058824 0.913725490196078];
            app.connectButton.FontSize = 26.6666666666667;
            app.connectButton.FontColor = [0.709803921568627 0.513725490196078 0.552941176470588];
            app.connectButton.Position = [62 434 161 73];
            app.connectButton.Text = 'Connect';

            % Create disconnectButton
            app.disconnectButton = uibutton(app.UIFigure, 'push');
            app.disconnectButton.ButtonPushedFcn = createCallbackFcn(app, @disconnectButtonPushed, true);
            app.disconnectButton.Tag = 'disconnectButton';
            app.disconnectButton.BackgroundColor = [0.917647058823529 0.894117647058824 0.913725490196078];
            app.disconnectButton.FontSize = 26.6666666666667;
            app.disconnectButton.FontColor = [0.709803921568627 0.513725490196078 0.552941176470588];
            app.disconnectButton.Position = [62 349 161 75];
            app.disconnectButton.Text = 'Disconnect';

            % Create PEditFieldLabel
            app.PEditFieldLabel = uilabel(app.UIFigure);
            app.PEditFieldLabel.HorizontalAlignment = 'right';
            app.PEditFieldLabel.Position = [113 191 25 22];
            app.PEditFieldLabel.Text = 'P';

            % Create PEditField
            app.PEditField = uieditfield(app.UIFigure, 'numeric');
            app.PEditField.ValueDisplayFormat = '%.0f';
            app.PEditField.ValueChangedFcn = createCallbackFcn(app, @PEditFieldValueChanged, true);
            app.PEditField.Position = [149 192 100 22];

            % Create IEditFieldLabel
            app.IEditFieldLabel = uilabel(app.UIFigure);
            app.IEditFieldLabel.HorizontalAlignment = 'right';
            app.IEditFieldLabel.Position = [113 164 25 22];
            app.IEditFieldLabel.Text = 'I';

            % Create IEditField
            app.IEditField = uieditfield(app.UIFigure, 'numeric');
            app.IEditField.ValueDisplayFormat = '%.0f';
            app.IEditField.ValueChangedFcn = createCallbackFcn(app, @IEditFieldValueChanged, true);
            app.IEditField.Position = [149 164 100 22];

            % Create DEditFieldLabel
            app.DEditFieldLabel = uilabel(app.UIFigure);
            app.DEditFieldLabel.HorizontalAlignment = 'right';
            app.DEditFieldLabel.Position = [113 129 25 22];
            app.DEditFieldLabel.Text = 'D';

            % Create DEditField
            app.DEditField = uieditfield(app.UIFigure, 'numeric');
            app.DEditField.ValueDisplayFormat = '%.0f';
            app.DEditField.ValueChangedFcn = createCallbackFcn(app, @DEditFieldValueChanged, true);
            app.DEditField.Position = [149 129 100 22];

            % Create SettheValuesandSendViaSerialLabel
            app.SettheValuesandSendViaSerialLabel = uilabel(app.UIFigure);
            app.SettheValuesandSendViaSerialLabel.Position = [46 220 193 22];
            app.SettheValuesandSendViaSerialLabel.Text = 'Set the Values and Send Via Serial';

            % Create AnalogVoltageEditFieldLabel
            app.AnalogVoltageEditFieldLabel = uilabel(app.UIFigure);
            app.AnalogVoltageEditFieldLabel.HorizontalAlignment = 'right';
            app.AnalogVoltageEditFieldLabel.Position = [620 135 86 22];
            app.AnalogVoltageEditFieldLabel.Text = 'Analog Voltage';

            % Create AnalogVoltageEditField
            app.AnalogVoltageEditField = uieditfield(app.UIFigure, 'numeric');
            app.AnalogVoltageEditField.Position = [721 135 100 22];

            % Create ReferenceInputEditFieldLabel
            app.ReferenceInputEditFieldLabel = uilabel(app.UIFigure);
            app.ReferenceInputEditFieldLabel.HorizontalAlignment = 'right';
            app.ReferenceInputEditFieldLabel.Position = [45 97 91 22];
            app.ReferenceInputEditFieldLabel.Text = 'Reference Input';

            % Create ReferenceInputEditField
            app.ReferenceInputEditField = uieditfield(app.UIFigure, 'numeric');
            app.ReferenceInputEditField.ValueChangedFcn = createCallbackFcn(app, @ReferenceInputEditFieldValueChanged, true);
            app.ReferenceInputEditField.Position = [151 97 98 22];

            % Create SystemResponseEditFieldLabel
            app.SystemResponseEditFieldLabel = uilabel(app.UIFigure);
            app.SystemResponseEditFieldLabel.HorizontalAlignment = 'right';
            app.SystemResponseEditFieldLabel.Position = [603 104 103 22];
            app.SystemResponseEditFieldLabel.Text = 'System Response';

            % Create SystemResponseEditField
            app.SystemResponseEditField = uieditfield(app.UIFigure, 'numeric');
            app.SystemResponseEditField.Position = [721 104 100 22];

            % Create ConnectedLampLabel
            app.ConnectedLampLabel = uilabel(app.UIFigure);
            app.ConnectedLampLabel.HorizontalAlignment = 'right';
            app.ConnectedLampLabel.Position = [87 302 63 22];
            app.ConnectedLampLabel.Text = 'Connected';

            % Create ConnectedLamp
            app.ConnectedLamp = uilamp(app.UIFigure);
            app.ConnectedLamp.Position = [165 302 20 20];

            % Create SendButton
            app.SendButton = uibutton(app.UIFigure, 'push');
            app.SendButton.ButtonPushedFcn = createCallbackFcn(app, @SendButtonPushed, true);
            app.SendButton.Position = [151 58 100 22];
            app.SendButton.Text = 'Send';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = code_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end