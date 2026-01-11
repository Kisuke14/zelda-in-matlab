classdef Field
   
    properties (SetAccess = private)
        recBlackScreenLeft;
        recBlackScreenRight;

        ax;
        polyField;
        gridSize = [16 11];

        polyCave;
        buffPos;
        buffXlim;
        buffYlim;

        enemyMapCell;
    end

    methods
        function obj = Field(uiPanel)
            % Axes
            obj.ax = axes('Parent',uiPanel, 'Position',[0 0 1 1]);
            obj.ax.XLim = [7*16 8*16];
            obj.ax.YLim = [1*11 2*11];
            obj.ax.Toolbar.Visible = 'off'; % 右上にマウスをかざすと出てくるメニューバーを非表示
            set(obj.ax,'XTIck',[],'YTick',[]); % 目盛りの非表示
            hold(obj.ax,'on')

            % Field image
            spriteSheetField = imread("Images\Overworld - Overworld (First Quest).png");
            imgField = image(obj.ax, 'CData',spriteSheetField, 'XData',[0 16*16], 'YData',[11*9 0], 'Tag','Obstacle');

            % Obstacle Polygon
            polyData = table2array( readtable("mapPolygon.xlsx") );
            polyObs = polyshape(polyData(:,1)', polyData(:,2)');
            obj.polyField = plot(obj.ax, polyObs, 'LineStyle',"none" ,'FaceAlpha',0, 'Tag','Obstacle');

            % Obstacle Polygon
            polyData = table2array( readtable("cavePolygon.xlsx") );
            polyObs = polyshape(polyData(:,1)', polyData(:,2)');
            obj.polyCave = plot(obj.ax, polyObs, 'LineStyle',"none" ,'FaceAlpha',0, 'Tag','Cave');

            % Rectangle for Scene Change
            imBlack = zeros(525,765,3);
            obj.recBlackScreenLeft = uiimage(uiPanel, "ImageSource",imBlack, "Position",[0 0 1 526], "ScaleMethod","stretch");
            obj.recBlackScreenRight = uiimage(uiPanel, "ImageSource",imBlack, "Position",[765 0 1 526], "ScaleMethod","stretch");

            % Position Map for Enemy
            obj.enemyMapCell = readcell("posEnemy.xlsx");
        end

        function [obj, Hud, Link, Octarock] = changedArea(obj, Hud, Link, Octarock)
            if Link.posX < obj.ax.XLim(1) %左へのエリアチェンジ
                % obj.axField.XLim = obj.axField.XLim - 16;
                for i = 1:32
                    obj.ax.XLim = obj.ax.XLim - 0.5;
                    Link = Link.setPosition(Link.posX-1/32, Link.posY);
                    pause(1/32);
                end
                % MiniMapの更新
                Hud = Hud.updateRecPos(Hud.recMap.Position(1)-1, Hud.recMap.Position(2));
                % 敵のスポーン処理
                hexStr = obj.enemyMapCell{12-Hud.recMap.Position(2), Hud.recMap.Position(1)};   % mapに格納された二桁の16進数を取得
                val = hex2dec(hexStr);                                                          % 16進数を10進数に変換
                if val ~= 0
                    x = bitshift(val, -4);                                                      % 上位4ビット(10の位)をx座標として格納
                    y = bitand(val, 15);                                                        % 下位4ビット(1の位)をy座標として格納
                    Octarock = Octarock.despawn;                                                % エリア内の敵を一度消去
                    Octarock = Octarock.spawn(obj.ax.XLim(1)+x, obj.ax.YLim(1)+y);              % 敵のスポーン
                end
            elseif (Link.posX+Link.widImg) > obj.ax.XLim(2) %右へのエリアチェンジ
                % obj.axField.XLim = obj.axField.XLim + 16;
                for i = 1:32
                    obj.ax.XLim = obj.ax.XLim + 0.5;
                    Link = Link.setPosition(Link.posX+1/32, Link.posY);
                    pause(1/32);
                end
                % MiniMapの更新
                Hud = Hud.updateRecPos(Hud.recMap.Position(1)+1, Hud.recMap.Position(2));
                % 敵のスポーン処理
                hexStr = obj.enemyMapCell{12-Hud.recMap.Position(2), Hud.recMap.Position(1)};   % mapに格納された二桁の16進数を取得
                val = hex2dec(hexStr);                                                          % 16進数を10進数に変換
                if val ~= 0
                    x = bitshift(val, -4);                                                      % 上位4ビット(10の位)をx座標として格納
                    y = bitand(val, 15);                                                        % 下位4ビット(1の位)をy座標として格納
                    Octarock = Octarock.despawn;                                                % エリア内の敵を一度消去
                    Octarock = Octarock.spawn(obj.ax.XLim(1)+x, obj.ax.YLim(1)+y);              % 敵のスポーン
                end
            elseif Link.posY < obj.ax.YLim(1) %下へのエリアチェンジ
                % obj.axField.YLim = obj.axField.YLim - 11;
                for i = 1:22
                    obj.ax.YLim = obj.ax.YLim - 0.5;
                    Link = Link.setPosition(Link.posX, Link.posY-1/22);
                    pause(1/22);
                end
                % MiniMapの更新
                Hud = Hud.updateRecPos(Hud.recMap.Position(1), Hud.recMap.Position(2)-1);
                % 敵のスポーン処理
                hexStr = obj.enemyMapCell{12-Hud.recMap.Position(2), Hud.recMap.Position(1)};   % mapに格納された二桁の16進数を取得
                val = hex2dec(hexStr);                                                          % 16進数を10進数に変換
                if val ~= 0
                    x = bitshift(val, -4);                                                      % 上位4ビット(10の位)をx座標として格納
                    y = bitand(val, 15);                                                        % 下位4ビット(1の位)をy座標として格納
                    Octarock = Octarock.despawn;                                                % エリア内の敵を一度消去
                    Octarock = Octarock.spawn(obj.ax.XLim(1)+x, obj.ax.YLim(1)+y);              % 敵のスポーン
                end
            elseif (Link.posY+Link.heiImg) > obj.ax.YLim(2) %上へのエリアチェンジ
                % obj.axField.YLim = obj.axField.YLim + 11;
                for i = 1:22
                    obj.ax.YLim = obj.ax.YLim + 0.5;
                    Link = Link.setPosition(Link.posX, Link.posY+1/22);
                    pause(1/22);
                end
                % MiniMapの更新
                Hud = Hud.updateRecPos(Hud.recMap.Position(1), Hud.recMap.Position(2)+1);
                % 敵のスポーン処理
                hexStr = obj.enemyMapCell{12-Hud.recMap.Position(2), Hud.recMap.Position(1)};   % mapに格納された二桁の16進数を取得
                val = hex2dec(hexStr);                                                          % 16進数を10進数に変換
                if val ~= 0
                    x = bitshift(val, -4);                                                      % 上位4ビット(10の位)をx座標として格納
                    y = bitand(val, 15);                                                        % 下位4ビット(1の位)をy座標として格納
                    Octarock = Octarock.despawn;                                                % エリア内の敵を一度消去
                    Octarock = Octarock.spawn(obj.ax.XLim(1)+x, obj.ax.YLim(1)+y);              % 敵のスポーン
                end
            end
        end

        function [obj, Link] = entryCave(obj, Link)
            polyOverlapped = intersect(Link.polyMove.Shape, obj.polyCave.Shape);
            N = numsides(polyOverlapped);
            if N > 0
                % buffer
                obj.buffPos = [Link.posX, Link.posY];
                obj.buffXlim = obj.ax.XLim;
                obj.buffYlim = obj.ax.YLim;

                % Screen Close
                for i = 1:20
                    obj = obj.moveRecScreen(obj.recBlackScreenLeft.Position(3) + 765/2/20, 526, ...
                                            obj.recBlackScreenRight.Position(3) + 765/2/20, 526);
                    pause(1/25);
                end
                pause(1/10);

                % Area Change
                obj.ax.XLim = [0 16];
                obj.ax.YLim = [0 11];
                Link = Link.setPosition(7.5, 0);
                pause(1/10);

                % Screen Open
                for i = 1:20
                    obj = obj.moveRecScreen(obj.recBlackScreenLeft.Position(3) - 765/2/20, 526, ...
                                            obj.recBlackScreenRight.Position(3) - 765/2/20, 526);
                    pause(1/25);
                end
            end
        end

        function [obj, Link] = exitCave(obj, Link)
            if Link.posY < 0
                % Screen Close
                for i = 1:20
                    obj = obj.moveRecScreen(obj.recBlackScreenLeft.Position(3) + 765/2/20, 526, ...
                                            obj.recBlackScreenRight.Position(3) + 765/2/20, 526);
                    pause(1/25);
                end
                pause(1/10);

                % Area Change
                obj.ax.XLim = obj.buffXlim;
                obj.ax.YLim = obj.buffYlim;
                Link = Link.setPosition(obj.buffPos(1), obj.buffPos(2)-0.5);

                % Screen Open
                for i = 1:20
                    obj = obj.moveRecScreen(obj.recBlackScreenLeft.Position(3) - 765/2/20, 526, ...
                                            obj.recBlackScreenRight.Position(3) - 765/2/20, 526);
                    pause(1/25);
                end
            end
        end

        function obj = moveRecScreen(obj, widLeft, heiLeft, widRight, heiRight)
            obj.recBlackScreenLeft.Position = [0, 0, widLeft, heiLeft];
            obj.recBlackScreenRight.Position = [765-widRight, 0, widRight, heiRight];
        end
    end

end