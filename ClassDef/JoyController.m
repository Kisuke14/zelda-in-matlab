classdef JoyController
   
    properties (SetAccess = private)
        % Right Button State
        isPushed_Y = 0;
        isPushed_X = 0;
        isPushed_B = 0;
        isPushed_A = 0;
        isPushed_R = 0;
        isPushed_ZR = 0;
        % Center Button State
        isPushed_Minus = 0;
        isPushed_Plus = 0;
        isPushed_Rstick = 0;
        isPushed_Lstick = 0;
        isPushed_Home = 0;
        isPushed_Capture = 0;
        % Left Button State
        isPushed_Down = 0;
        isPushed_Up = 0;
        isPushed_Right = 0;
        isPushed_Left = 0;
        isPushed_L = 0;
        isPushed_ZL = 0;
        % Joy Stick
        rowHorLeft = 0;
        rowVerLeft = 0;
        dirLeftStick = '';
        rowHorRight = 0;
        rowVerRight = 0;
        dirRightStick = '';
        % IMU Sensor (Acceleration)
        accel_X = 0;
        accel_Y = 0;
        accel_Z = 0;
        % IMU Sensor (Gyro)
        gyro_X = 0;
        gyro_Y = 0;
        gyro_Z = 0;
        % Attitude
        roll = 0;
        pitch = 0;
        yaw = 0;
        % Kalman Filter
        PEst;
    end

    methods
        function obj = JoyController()
            %
        end

        function obj = getBtnState(obj, rmsg)
            obj.isPushed_Y = bitget(rmsg(4), 1);
            obj.isPushed_X = bitget(rmsg(4), 2);
            obj.isPushed_B = bitget(rmsg(4), 3);
            obj.isPushed_A = bitget(rmsg(4), 4);
            obj.isPushed_R = bitget(rmsg(4), 7);
            obj.isPushed_ZR = bitget(rmsg(4), 8);

            obj.isPushed_Minus = bitget(rmsg(5), 1);
            obj.isPushed_Plus = bitget(rmsg(5), 2);
            obj.isPushed_Rstick = bitget(rmsg(5), 3);
            obj.isPushed_Lstick = bitget(rmsg(5), 4);
            obj.isPushed_Home = bitget(rmsg(5), 5);
            obj.isPushed_Capture = bitget(rmsg(5), 6);
            
            obj.isPushed_Down = bitget(rmsg(6), 1);
            obj.isPushed_Up = bitget(rmsg(6), 2);
            obj.isPushed_Right = bitget(rmsg(6), 3);
            obj.isPushed_Left = bitget(rmsg(6), 4);
            obj.isPushed_L = bitget(rmsg(6), 7);
            obj.isPushed_ZL = bitget(rmsg(6), 8);
        end

        function obj = getJoyStickState(obj, rmsg)
            rangeNeutralJoystick = [1800 2300];
            posNeutralJoystick = 2100;

            % 左スティック状態のrow valueを取得
            rowData(1) = uint16(rmsg(7)); %Left 1st Byte
            rowData(2) = uint16(rmsg(8)); %Left 2nd Byte
            rowData(3) = uint16(rmsg(9)); %Left 3rd Byte
            obj.rowHorLeft = bitor(rowData(1), bitshift(bitand(rowData(2), uint16(0xF)), 8)); %2ndByteの下位4bit+1stByteで12bitを作る
            obj.rowVerLeft = bitor(bitshift(rowData(2), -4), bitshift(rowData(3), 4));        %3rdByte+2ndByteの上位4bitで12bitを作る

            % 右スティック状態のrow valueを取得
            rowData(1) = uint16(rmsg(10)); %Right 1st Byte
            rowData(2) = uint16(rmsg(11)); %Right 2nd Byte
            rowData(3) = uint16(rmsg(12)); %Right 3rd Byte
            obj.rowHorRight = bitor(rowData(1), bitshift(bitand(rowData(2), uint16(0xF)), 8)); %2ndByteの下位4bit+1stByteで12bitを作る
            obj.rowVerRight = bitor(bitshift(rowData(2), -4), bitshift(rowData(3), 4));        %3rdByte+2ndByteの上位4bitで12bitを作る

            % 左スティックの方向判別
            if (rangeNeutralJoystick(1) < obj.rowHorLeft && obj.rowHorLeft < rangeNeutralJoystick(2)) && ...
               (rangeNeutralJoystick(1) < obj.rowVerLeft && obj.rowVerLeft < rangeNeutralJoystick(2))
                % Neutralからの移動量が規定範囲以内
                obj.dirLeftStick = 'neutral';
            else
                % スティックが規定範囲以上動いている
                if abs(single(obj.rowHorLeft)-posNeutralJoystick) < abs(single(obj.rowVerLeft)-posNeutralJoystick)
                    % 垂直方向の移動量が水平方向の移動量より大きい
                    if 0 < (single(obj.rowVerLeft)-posNeutralJoystick)
                        % 生値が増加する方向（上方向）への移動
                        obj.dirLeftStick = 'up'; % 
                    else
                        % 生値が減少する方向（下方向）への移動
                        obj.dirLeftStick = 'down';
                    end
                else
                    % 水平方向の移動量が垂直方向の移動量より大きい
                    if 0 < (single(obj.rowHorLeft)-posNeutralJoystick)
                        % 生値が増加する方向（右方向）への移動
                        obj.dirLeftStick = 'right';
                    else
                        % 生値が増加する方向（左方向）への移動
                        obj.dirLeftStick = 'left';
                    end
                end
            end

            % 右スティックの方向判別
            if (rangeNeutralJoystick(1) < obj.rowHorRight && obj.rowHorRight < rangeNeutralJoystick(2)) && ...
               (rangeNeutralJoystick(1) < obj.rowVerRight && obj.rowVerRight < rangeNeutralJoystick(2))
                % Neutralからの移動量が規定範囲以内
                obj.dirRightStick = 'neutral';
            else
                % スティックが規定範囲以上動いている
                if abs(single(obj.rowHorRight)-posNeutralJoystick) < abs(single(obj.rowVerRight)-posNeutralJoystick)
                    % 垂直方向の移動量が水平方向の移動量より大きい
                    if 0 < (single(obj.rowVerRight)-posNeutralJoystick)
                        % 生値が増加する方向（上方向）への移動
                        obj.dirRightStick = 'up'; % 
                    else
                        % 生値が減少する方向（下方向）への移動
                        obj.dirRightStick = 'down';
                    end
                else
                    % 水平方向の移動量が垂直方向の移動量より大きい
                    if 0 < (single(obj.rowHorRight)-posNeutralJoystick)
                        % 生値が増加する方向（右方向）への移動
                        obj.dirRightStick = 'right';
                    else
                        % 生値が増加する方向（左方向）への移動
                        obj.dirRightStick = 'left';
                    end
                end
            end
        end

        function obj = getAcceleration(obj, rmsg)
            % Parameters
            offset_X = 350;               % Reverse Engineering参照
            coefficient = 0.000244 * 9.8; % Reverse Engineering参照

            % X
            hByteBe = uint16(rmsg(14));
            lByteBe = uint16(rmsg(15));
            uint16Le = bitor(bitshift(lByteBe,8), hByteBe);
            int16Le = typecast(uint16Le, 'int16') - offset_X;
            obj.accel_X = double(int16Le) * coefficient;

            % Y
            hByteBe = uint16(rmsg(16));
            lByteBe = uint16(rmsg(17));
            uint16Le = bitor(bitshift(lByteBe,8), hByteBe);
            int16Le = typecast(uint16Le, 'int16');
            obj.accel_Y = double(int16Le) * coefficient;

            % Z
            hByteBe = uint16(rmsg(18));
            lByteBe = uint16(rmsg(19));
            uint16Le = bitor(bitshift(lByteBe,8), hByteBe);
            int16Le = typecast(uint16Le, 'int16');
            obj.accel_Z = double(int16Le) * coefficient;
        end

        function obj = getGyro(obj, rmsg)
            % Parameters
            coefficient = 0.06103 / 180 * pi; % Reverse Engineering参照

            % X
            hByteBe = uint16(rmsg(20));
            lByteBe = uint16(rmsg(21));
            uint16Le = bitor(bitshift(lByteBe,8), hByteBe);
            int16Le = typecast(uint16Le, 'int16');
            obj.gyro_X = double(int16Le) * coefficient;

            % Y
            hByteBe = uint16(rmsg(22));
            lByteBe = uint16(rmsg(23));
            uint16Le = bitor(bitshift(lByteBe,8), hByteBe);
            int16Le = typecast(uint16Le, 'int16');
            obj.gyro_Y = double(int16Le) * coefficient;

            % Z
            hByteBe = uint16(rmsg(24));
            lByteBe = uint16(rmsg(25));
            uint16Le = bitor(bitshift(lByteBe,8), hByteBe);
            int16Le = typecast(uint16Le, 'int16');
            obj.gyro_Z = double(int16Le) * coefficient;
        end

        function obj = setPEst4KalmanFilter(obj, dt)
            obj.PEst = eye(2) * 0.0174 * dt^2;
        end

        function obj = estimateEulerAngle(obj, rmsg, dt)
            % Parameters
            Q = eye(2) * 0.0174 * dt^2;
            R = eye(2) * dt^2;
            H = eye(2);

            if isempty(obj.PEst)
                obj = obj.setPEst4KalmanFilter(dt);
            end

            % 加速度から角度を計算（観測値）
            obj = obj.getAcceleration(rmsg);
            rollAcc = atan2(obj.accel_Y, obj.accel_Z);
            pitchAcc = -atan2(obj.accel_X, sqrt(obj.accel_Y^2 + obj.accel_Z^2));
            y = [rollAcc, pitchAcc]';

            % ジャイロから角度を計算（予測値）
            obj = obj.getGyro(rmsg);
            droll = obj.gyro_X + sin(obj.roll)*tan(obj.pitch)*obj.gyro_Y + cos(obj.roll)*tan(obj.pitch)*obj.gyro_Z;
            dpitch = cos(obj.roll)*obj.gyro_Y - sin(obj.roll)*obj.gyro_Z;
            dyaw = sin(obj.roll)/cos(obj.pitch)*obj.gyro_Y + cos(obj.roll)/cos(obj.pitch)*obj.gyro_Z;
            
            rollGyro = obj.roll + droll*dt;
            pitchGyro = obj.pitch + dpitch*dt;
            yawGyro = obj.yaw + dyaw*dt;
            
            xPred = [rollGyro, pitchGyro]';

            % ヤコビ行列の計算
            F = zeros(2,2);
            F(1,1) = 1 + (obj.gyro_Y*cos(obj.roll)*tan(obj.pitch)-obj.gyro_Z*sin(obj.roll)*tan(obj.pitch))*dt;
            F(1,2) = (obj.gyro_Y*sin(obj.roll)/(cos(obj.pitch)^2)+obj.gyro_Z*cos(obj.roll)/(cos(obj.pitch)^2))*dt;
            F(2,1) = (-obj.gyro_Y*sin(obj.roll)+obj.gyro_Z*cos(obj.roll))*dt;
            F(2,2) = 1;

            % 更新
            PPred = F*obj.PEst*F'+Q;
            K = PPred*H'/(H*PPred*H'+R);
            xEst = xPred + K*(y-H*xPred);
            obj.PEst = (eye(2)-K*H)*PPred;
            
            obj.roll = xEst(1);
            obj.pitch = xEst(2);
            obj.yaw = yawGyro;
        end
    end

end