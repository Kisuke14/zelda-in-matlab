classdef HUD
   
    properties (SetAccess = private)
        axMap;
        recMap;

        hudSpriteSheet;
        nBomb = 0;
        nKey = 0;
        nRupee = 0;
        imgNum;
        imgHeart;
    end

    methods
        function obj = HUD(mapPanel, hudPanel)
            %%% MiniMap
            obj.axMap = uiaxes('Parent',mapPanel, 'Units','pixels', 'Position',[48 27 186 117], 'Color',[0.5 0.5 0.5]);
            obj.axMap.XLim = [1 17];
            obj.axMap.YLim = [1 9];
            obj.axMap.Toolbar.Visible = 'off'; % 右上にマウスをかざすと出てくるメニューバーを非表示
            set(obj.axMap,'XTIck',[],'YTick',[]); % 目盛りの非表示

            obj.recMap = rectangle(obj.axMap, 'FaceColor',[146/255 238/255 0/255], ...
                                              'EdgeColor',[146/255 238/255 0/255], 'Position',[8 1 1 1]);

            %%% HUD
            % Frame
            obj.hudSpriteSheet = imread("Images\Miscellaneous - HUD & Pause Screen.png");
            imHud = obj.hudSpriteSheet(12:67,347:514,:);
            hud = uiimage(hudPanel, "ImageSource",imHud, "Position",[0 0 500 165]);

            % Font
            imX(1) = uiimage(hudPanel, "ImageSource",obj.hudSpriteSheet(118:125,520:527,:), "Position",[28 23 23 23]);
            imX(2) = uiimage(hudPanel, "ImageSource",obj.hudSpriteSheet(118:125,520:527,:), "Position",[28 47 23 23]);
            imX(3) = uiimage(hudPanel, "ImageSource",obj.hudSpriteSheet(118:125,520:527,:), "Position",[28 94 23 23]);
            obj.imgNum(1) = uiimage(hudPanel, "ImageSource",obj.hudSpriteSheet(118:125,529:536,:), "Position",[51 23 23 23]);
            obj.imgNum(2) = uiimage(hudPanel, "ImageSource",obj.hudSpriteSheet(118:125,529:536,:), "Position",[74 23 23 23]);
            obj.imgNum(3) = uiimage(hudPanel, "ImageSource",obj.hudSpriteSheet(118:125,529:536,:), "Position",[51 47 23 23]);
            obj.imgNum(4) = uiimage(hudPanel, "ImageSource",obj.hudSpriteSheet(118:125,529:536,:), "Position",[74 47 23 23]);
            obj.imgNum(5) = uiimage(hudPanel, "ImageSource",obj.hudSpriteSheet(118:125,529:536,:), "Position",[51 94 23 23]);
            obj.imgNum(6) = uiimage(hudPanel, "ImageSource",obj.hudSpriteSheet(118:125,529:536,:), "Position",[74 94 23 23]);

            %%% AB Items
            imBlack(1) = uiimage(hudPanel, "ImageSource",obj.hudSpriteSheet(35:52,424:433,:), "Position",[118 45 28 50], "ScaleMethod","stretch");
            imBlack(2) = uiimage(hudPanel, "ImageSource",obj.hudSpriteSheet(35:52,424:433,:), "Position",[189 45 28 50], "ScaleMethod","stretch");

            % imgTemp = obj.hudSpriteSheet(138:153,556:563,:);
            % isColored = imgTemp(:,:,1) ~= 116 & imgTemp(:,:,2) ~= 116 & imgTemp(:,:,3) ~= 116;
            % alphaMap = ones(size(imgTemp(:,:,1))) .* isColored;
            % imSword = uiimage(hudPanel, "ImageSource",obj.hudSpriteSheet(138:153,556:563,:), "Position",[189 45 28 50], "ScaleMethod","stretch");

            %%% Hearts
            imBlackBackground = uiimage(hudPanel, "ImageSource",zeros(42,120,3), "Position",[259 22 192 50], "ScaleMethod","stretch");
            obj.imgHeart{1} = uiimage(hudPanel, "ImageSource",obj.hudSpriteSheet(118:125,646:653,:), "Position",[260 23 24 24]);
            obj.imgHeart{2} = uiimage(hudPanel, "ImageSource",obj.hudSpriteSheet(118:125,646:653,:), "Position",[284 23 24 24]);
            obj.imgHeart{3} = uiimage(hudPanel, "ImageSource",obj.hudSpriteSheet(118:125,646:653,:), "Position",[308 23 24 24]);
            obj.imgHeart{4} = uiimage(hudPanel, "ImageSource",obj.hudSpriteSheet(150:157,500:507,:), "Position",[332 23 24 24]);
            obj.imgHeart{5} = uiimage(hudPanel, "ImageSource",obj.hudSpriteSheet(150:157,500:507,:), "Position",[356 23 24 24]);
            obj.imgHeart{6} = uiimage(hudPanel, "ImageSource",obj.hudSpriteSheet(150:157,500:507,:), "Position",[380 23 24 24]);
            obj.imgHeart{7} = uiimage(hudPanel, "ImageSource",obj.hudSpriteSheet(150:157,500:507,:), "Position",[404 23 24 24]);
            obj.imgHeart{8} = uiimage(hudPanel, "ImageSource",obj.hudSpriteSheet(150:157,500:507,:), "Position",[428 23 24 24]);
            obj.imgHeart{9} = uiimage(hudPanel, "ImageSource",obj.hudSpriteSheet(150:157,500:507,:), "Position",[260 47 24 24]);
            obj.imgHeart{10} = uiimage(hudPanel, "ImageSource",obj.hudSpriteSheet(150:157,500:507,:), "Position",[284 47 24 24]);
            obj.imgHeart{11} = uiimage(hudPanel, "ImageSource",obj.hudSpriteSheet(150:157,500:507,:), "Position",[308 47 24 24]);
            obj.imgHeart{12} = uiimage(hudPanel, "ImageSource",obj.hudSpriteSheet(150:157,500:507,:), "Position",[332 47 24 24]);
            obj.imgHeart{13} = uiimage(hudPanel, "ImageSource",obj.hudSpriteSheet(150:157,500:507,:), "Position",[356 47 24 24]);
            obj.imgHeart{14} = uiimage(hudPanel, "ImageSource",obj.hudSpriteSheet(150:157,500:507,:), "Position",[380 47 24 24]);
            obj.imgHeart{15} = uiimage(hudPanel, "ImageSource",obj.hudSpriteSheet(150:157,500:507,:), "Position",[404 47 24 24]);
            obj.imgHeart{16} = uiimage(hudPanel, "ImageSource",obj.hudSpriteSheet(150:157,500:507,:), "Position",[428 47 24 24]);
        end

        function obj = updateRecPos(obj, x, y)
            obj.recMap.Position = [x, y, 1, 1];
        end

        function obj = updateIcons(obj, Link)
            for i = 1:16
                if Link.maxHP >= i
                    if Link.curHP >= i
                        % Full
                        obj.imgHeart{i}.ImageSource = obj.hudSpriteSheet(118:125,646:653,:);
                    else
                        if Link.curHP > i-0.9
                            % Half
                            obj.imgHeart{i}.ImageSource = obj.hudSpriteSheet(118:125,637:644,:);
                        else
                            % Empty
                            obj.imgHeart{i}.ImageSource = obj.hudSpriteSheet(118:125,628:635,:);
                        end
                    end
                else
                    % Black
                    obj.imgHeart{i}.ImageSource = obj.hudSpriteSheet(150:157,500:507,:);
                end
            end
        end
     end
end