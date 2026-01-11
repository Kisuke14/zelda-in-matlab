classdef UI
   
    properties (SetAccess = private)
        fig;
        mapPanel;
        hudPanel;
        fieldPanel;
    end

    methods
        function obj = UI()
            % UI-Figure & Panels
            obj.fig = uifigure('Name','My Game', 'Position',[200 200 765 690], 'Units','pixels');
            obj.mapPanel = uipanel(obj.fig, 'Units','pixels', 'Position',[0 525 265 165], 'BackgroundColor',[0 0 0], 'BorderType','none');
            obj.hudPanel = uipanel(obj.fig, 'Units','pixels', 'Position',[265 525 500 165], 'BackgroundColor',[0 0 0], 'BorderType','none');
            obj.fieldPanel = uipanel(obj.fig, 'Units','pixels', 'Position',[0 0 765 525], 'BackgroundColor',[0 0 0], 'BorderType','none');

            % UserData
            obj.fig.UserData = struct('currentKey', '', ...
                                      'bufferKey','', ...
                                      'isClick',false, ...
                                      'isRightClick',false);

            % Callback Function
            obj.fig.KeyPressFcn = @keyPrsFnc;
            obj.fig.KeyReleaseFcn = @keyRlsFnc;
            obj.fig.WindowButtonDownFcn = @btnDownFnc;

            function keyPrsFnc(src, data)
                if ~strcmp(src.UserData.currentKey, data.Key)
                    %前と異なるKeyが押された場合、前に押していたKeyをバッファに格納
                    src.UserData.bufferKey = src.UserData.currentKey;
                end
                src.UserData.currentKey = data.Key;
            end

            function keyRlsFnc(src, data)
                if strcmp(src.UserData.currentKey, data.Key)
                    %最後に押しているKeyを離した場合、前に離したKeyを採用
                    src.UserData.currentKey = src.UserData.bufferKey;
                    src.UserData.bufferKey = '';
                else
                    %別のKeyが押される前から押しっぱなしのKeyを離した場合、bufferKeyをクリア
                    src.UserData.bufferKey = '';
                end
            end

            function btnDownFnc(src, data)
                switch(data.Source.SelectionType)
                    case 'normal'   %左クリック
                        src.UserData.isClick = true;
                    case 'alt'      %右クリック
                        src.UserData.isRightClick = true;
                    case 'open'     %ダブルクリック
                        src.UserData.isClick = true;
                    case 'extend'   %同時クリック/ホイールクリック
                        src.UserData.isClick = true;
                end
            end
        end
    end

end