classdef Enemy

    properties (SetAccess = private)
        spawned = false;
        maxHP = 1;
        curHP = 1;
        power = 1;

        posX = -2;
        posY = 0;
        vX = 0;
        vY = 0;
        direction = 'left';

        heiImg = 1;
        widImg = 1;
        offsetX = 0;
        offsetY = 0;

        spriteSheet;
        spriteSheetEffect;
        spriteSheetSmoke;
        imgSrc;
        objImg;

        heiPoly = 1;
        widPoly = 1;
        poly;

        cntStep = 0;
        cntAttack = 0;
        cntDamaged = 0;
        cntSpawned = 0;
    end

    methods
        function obj = Enemy(ax)
            obj.spriteSheet = imread("Images\Enemies & Bosses - Overworld Enemies.png");
            obj.spriteSheetEffect = imread("Images\Miscellaneous - Enemy Death.png");
            obj.spriteSheetSmoke = imread("Images\Playable Characters - Link.png");
            obj.imgSrc = obj.spriteSheet(12:27,53:68,:);

            isColored = obj.imgSrc(:,:,1) ~= 116 & obj.imgSrc(:,:,2) ~= 116 & obj.imgSrc(:,:,3) ~= 116;
            alphaMap = ones(size(obj.imgSrc(:,:,1))) .* isColored;

            obj.objImg = image(ax, 'CData',obj.imgSrc, 'XData',[0 1], 'YData',[1 0], 'AlphaData',alphaMap);
            poly = polyshape([0 0 1 1], [0 1 1 0]);
            obj.poly = plot(ax, poly, 'LineStyle',"none", 'FaceAlpha',0);
        end

        function obj = updatePos(obj, polyField)
            %障害物との衝突オフセット
            polyEnemyTemp = translate(obj.poly.Shape, [obj.vX obj.vY]);
            polyInter = intersect(polyEnemyTemp, polyField.Shape);
            if isempty(polyInter.Vertices)
                shiftX = 0;
                shiftY = 0;
            else
                shiftX = max(polyInter.Vertices(:,1)) - min(polyInter.Vertices(:,1));
                shiftY = max(polyInter.Vertices(:,2)) - min(polyInter.Vertices(:,2));
            end

            %posX, posYの更新
            obj.posX = obj.posX + obj.vX - shiftX * sign(obj.vX); 
            obj.posY = obj.posY + obj.vY - shiftY * sign(obj.vY);
        end

        function updateObjImgPolygon(obj)
            %Image
            xS = obj.posX + obj.offsetX;
            xE = xS + obj.widImg;
            yS = obj.posY + obj.offsetY;
            yE = yS + obj.heiImg;
            obj.objImg.XData = [xS xE];
            obj.objImg.YData = [yE yS];

            obj.objImg.CData = obj.imgSrc;
            isColored = obj.imgSrc(:,:,1) ~= 116 & obj.imgSrc(:,:,2) ~= 116 & obj.imgSrc(:,:,3) ~= 116;
            alphaMap = ones(size(obj.imgSrc(:,:,1))) .* isColored;
            obj.objImg.AlphaData = alphaMap;

            %Polygon
            xS = obj.posX;
            xE = xS + obj.widPoly;
            yS = obj.posY;
            yE = yS + obj.heiPoly;
            obj.poly.Shape.Vertices(:,1) = [xS xS xE xE];
            obj.poly.Shape.Vertices(:,2) = [yS yE yE yS];
        end

        function obj = spawn(obj, x, y)
            if obj.cntSpawned == 0
                obj.cntSpawned = 12;
                obj.posX = x;
                obj.posY = y;
            elseif obj.cntSpawned > 7
                obj.imgSrc = obj.spriteSheetSmoke(186:201,139:154,:);
            elseif obj.cntSpawned > 5
                obj.imgSrc = obj.spriteSheetSmoke(186:201,156:171,:);
            elseif obj.cntSpawned > 3
                obj.imgSrc = obj.spriteSheetSmoke(186:201,173:188,:);
            elseif obj.cntSpawned == 1
                obj.spawned = true;
                obj.imgSrc = obj.spriteSheet(12:27,53:68,:);
            end

            obj.updateObjImgPolygon;

            %cntEffectの更新
            obj.cntSpawned = max(obj.cntSpawned-1, 0);
        end

        function obj = despawn(obj)
            obj.spawned = false;
            obj.cntSpawned = 0;
            obj.vX = 0;
            obj.vY = 0;
            obj.posX = -2;
            obj.posX = 1;
        end

        function obj = vanish(obj)
            obj.spawned = false;
            cntInit = 22;

            if obj.cntDamaged == 0
                obj.cntDamaged = cntInit;
                obj.imgSrc = obj.spriteSheetEffect(1:16,49:63,:);
            elseif obj.cntDamaged > 18
                obj.imgSrc = obj.spriteSheetEffect(1:16,33:47,:);
            elseif obj.cntDamaged > 15
                obj.imgSrc = obj.spriteSheetEffect(1:16,17:31,:);
            elseif obj.cntDamaged > 12
                obj.imgSrc = obj.spriteSheetEffect(1:16,1:15,:);
            elseif obj.cntDamaged > 9
                obj.imgSrc = obj.spriteSheetEffect(1:16,17:31,:);
            elseif obj.cntDamaged > 6
                obj.imgSrc = obj.spriteSheetEffect(1:16,33:47,:);
            elseif obj.cntDamaged > 3
                obj.imgSrc = obj.spriteSheetEffect(1:16,49:63,:);
            elseif obj.cntDamaged == 1
                obj.posX = -2;
                obj.posY = 0;
            end

            obj.updateObjImgPolygon;
            obj.poly.Shape.Vertices(:,1) = [-2 -2 -1 -1];
            obj.poly.Shape.Vertices(:,2) = [0 1 1 0];

            %cntDamagedの更新
            obj.cntDamaged = max(obj.cntDamaged-1, 0);
        end

        function obj = move(obj, field, fps, Link)
            % Parameters
            threshCnt = 8;               % 歩いてるときに絵が切り替わるフレーム数
            movPerSec = 2;               % 1secごとの速度 ※2secで1画面(16)動く速度
            movPerFrm = movPerSec / fps; % 1フレームごとの速度

            %Direction
            diffX = Link.posX - obj.posX;
            diffY = Link.posY - obj.posY;
            if Link.cntDamaged > 0 
                % 常にLinkへ向かうようにするとDamage中に壁に押し込まれるので、
                % Damage中はLinkから離れるようにする
                diffX = -1 * diffX;
                diffY = -1 * diffY;
            end

            [~, idx] = max( abs([diffX, diffY]) );
            if idx == 1 % X成分の絶対値の方が大きい
                if diffX > 0
                    obj.direction = 'right';
                else
                    obj.direction = 'left';
                end
            else % idx == 2 Y成分の絶対値の方が大きい
                if diffY > 0
                    obj.direction = 'up';
                else
                    obj.direction = 'down';
                end
            end

            % Velocity & Image
            switch(obj.direction)
                case 'right'
                    obj.vX = movPerFrm;
                    obj.vY = 0;
        
                    % threshCntごとに2種類の画像を切り替える
                    if obj.cntStep < threshCnt
                        obj.imgSrc = fliplr(obj.spriteSheet(12:27,36:51,:));
                    else
                        obj.imgSrc = fliplr(obj.spriteSheet(12:27,53:68,:));
                    end
        
                case 'left'
                    obj.vX = -movPerFrm;
                    obj.vY = 0;
        
                    if obj.cntStep < threshCnt
                        obj.imgSrc = obj.spriteSheet(12:27,36:51,:);
                    else
                        obj.imgSrc = obj.spriteSheet(12:27,53:68,:);
                    end
        
                case 'up'
                    obj.vX = 0;
                    obj.vY = movPerFrm;
        
                    if obj.cntStep < threshCnt
                        obj.imgSrc = flipud(obj.spriteSheet(12:27,2:17,:));
                    else
                        obj.imgSrc = flipud(obj.spriteSheet(12:27,19:34,:));
                    end
        
                case 'down'
                    obj.vX = 0;
                    obj.vY = -movPerFrm;
        
                    if obj.cntStep < threshCnt
                        obj.imgSrc = obj.spriteSheet(12:27,2:17,:);
                    else
                        obj.imgSrc = obj.spriteSheet(12:27,19:34,:);
                    end
                otherwise
                    obj.vX = 0;
                    obj.vY = 0;
            end

            % cntStepの更新。threshCnt*2を超えたら0に戻るリングカウンタのような
            obj.cntStep = rem(obj.cntStep+1, threshCnt*2);

            % posX, posYの更新
            obj = obj.updatePos(field.polyField);
            
        end
    end

end