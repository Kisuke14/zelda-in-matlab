classdef PlayerCharacter

    properties (SetAccess = private)
        maxHP = 16;
        curHP = 16;
        power = 1;

        posX = 7*16+6;
        posY = 1*11+5;
        vX = 0;
        vY = 0;
        direction = 'front';

        heiImg = 1;
        widImg = 1;
        offsetX = 0;
        offsetY = 0;

        spriteSheet;
        imgSrc;
        objImg;

        heiPoly = 1;
        widPoly = 1;
        polyHit;
        polyMove;
        swordPoly;

        cntStep = 0;
        cntAttack = 0;
        cntDamaged = 0;
    end

    methods
        function obj = PlayerCharacter(ax)
            obj.spriteSheet = imread("Images\Playable Characters - Link.png");
            obj.imgSrc = obj.spriteSheet(12:27,2:17,:);
            obj.objImg = image(ax, 'CData',obj.imgSrc, 'XData',[7*16+6 7*16+7], 'YData',[1*11+6 1*11+5]);

            poly = polyshape([0 0 1 1], [0 1 1 0]);
            obj.polyHit = plot(ax, poly, 'LineStyle',"none", 'FaceAlpha',0);
            obj.polyMove = plot(ax, poly, 'LineStyle',"none", 'FaceAlpha',0);

            poly = polyshape([-2 -2 -1 -1], [2 3 3 2]);
            obj.swordPoly = plot(ax, poly, 'LineStyle',"none", 'FaceColor','b', 'FaceAlpha',0);
        end

        function obj = setPosition(obj, x, y)
            obj.posX = x;
            obj.posY = y;
            obj.updateObjImgPolygon;
        end

        function updateSwordPolygon(obj, xS, xE, yS, yE)
            obj.swordPoly.Shape.Vertices(:,1) = [xS xS xE xE];
            obj.swordPoly.Shape.Vertices(:,2) = [yS yE yE yS];
        end

        function updateObjImgPolygon(obj)
            % Image
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

            % Polygon for Hit
            xS = obj.posX;
            xE = xS + obj.widPoly;
            yS = obj.posY;
            yE = yS + obj.heiPoly;
            obj.polyHit.Shape.Vertices(:,1) = [xS xS xE xE];
            obj.polyHit.Shape.Vertices(:,2) = [yS yE yE yS];

            % Polygon for Move
            % 障害物との衝突計算用に別途polyを規定する
            % 敵との当たり判定は頭の先まであってほしいが、障害物との衝突判定が端から端まであると違和感な上に障害物の間を非常にすり抜けにくい
            xS = obj.posX + 0.2;
            xE = xS + 0.6;
            yS = obj.posY + 0.1;
            yE = yS + 0.5;
            obj.polyMove.Shape.Vertices(:,1) = [xS xS xE xE];
            obj.polyMove.Shape.Vertices(:,2) = [yS yE yE yS];
        end

        function obj = updatePos(obj, polyField)
            % Initialize
            polyLinkMoved = translate(obj.polyMove.Shape, [obj.vX, obj.vY]);
            shiftX = 0;
            shiftY = 0;

            polyOverlapped = intersect(polyLinkMoved, polyField.Shape);
            N = numsides(polyOverlapped);

            % polyMovedと障害物がめり込まず接しているだけの場合はシフトさせない
            % めり込み or 接触 の判定は交差したpolyshapeが多角形かどうか。線でしか交差しない場合はN=0になる。
            if N > 0
                for i = 1:4
                    % 四角の頂点ごとに、移動前から移動後に向けて線分を引き、その線分と障害物の交差した分だけシフトする。
                    % 頂点ごとの調停としては一番長い線分を採用し、その線分のX, Yだけシフトする
                    lineSeg = [obj.polyMove.Shape.Vertices(i,1), obj.polyMove.Shape.Vertices(i,2) ; 
                               polyLinkMoved.Vertices(i,1), polyLinkMoved.Vertices(i,2)];
                    [in, ~] = intersect(polyField.Shape, lineSeg);

                    if ~isempty(in)
                        vec = [shiftX, in(2,1)-in(1,1)];
                        [~, idx] = max(abs(vec));
                        shiftX = vec(idx);
                        vec = [shiftY, in(2,2)-in(1,2)];
                        [~, idx] = max(abs(vec));
                        shiftY = vec(idx);
                    end
                end
            end

            %posX, posYの更新
            obj.posX = obj.posX + obj.vX - shiftX;
            obj.posY = obj.posY + obj.vY - shiftY;

        end

        function obj = moveByKey(obj, dir, fps)

            %Parameters
            threshCnt = 3;               %歩いてるときに絵が切り替わるフレーム数
            movPerSec = 8;               %1secごとの速度 ※2secで1画面(16)動く速度
            movPerFrm = movPerSec / fps; %1フレームごとの速度

            %Direction & Velocity
            switch(dir)
                case 'right'
                    obj.direction = 'right';
                    obj.vX = movPerFrm;
                    obj.vY = 0;

                    %threshCntごとに2種類の画像を切り替える
                    if obj.cntStep < threshCnt
                        obj.imgSrc = obj.spriteSheet(12:27,36:51,:);
                    else
                        obj.imgSrc = obj.spriteSheet(12:27,53:68,:);
                    end

                case 'left'
                    obj.direction = 'left';
                    obj.vX = -movPerFrm;
                    obj.vY = 0;

                    if obj.cntStep < threshCnt
                        obj.imgSrc = fliplr(obj.spriteSheet(12:27,36:51,:));
                    else
                        obj.imgSrc = fliplr(obj.spriteSheet(12:27,53:68,:));
                    end

                case 'up'
                    obj.direction = 'back';
                    obj.vX = 0;
                    obj.vY = movPerFrm;

                    if obj.cntStep < threshCnt
                        obj.imgSrc = obj.spriteSheet(12:27,70:85,:);
                    else
                        obj.imgSrc = obj.spriteSheet(12:27,87:102,:);
                    end

                case 'down'
                    obj.direction = 'front';
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

            %cntStepの更新。threshCnt*2を超えたら0に戻るリングカウンタのような
            obj.cntStep = rem(obj.cntStep+1, threshCnt*2);

        end

        function obj = attackByClick(obj)

            %振りはじめ
            if obj.cntAttack == 0
                obj.cntAttack = 11;
                switch(obj.direction)
                    case 'right'
                        obj.imgSrc = obj.spriteSheet(78:93,2:17,:);
                    case 'left'
                        obj.imgSrc = fliplr(obj.spriteSheet(78:93,2:17,:));
                    case 'back'
                        obj.imgSrc = obj.spriteSheet(110:125,2:17,:);
                    case 'front'
                        obj.imgSrc = obj.spriteSheet(48:63,2:17,:);
                end
            end

            %振り最中
            if obj.cntAttack == 7
                switch(obj.direction)
                    case 'right'
                        obj.imgSrc = obj.spriteSheet(78:93,19:45,:);
                        obj.widImg = 1.733;
                        xS = obj.posX + obj.widPoly;
                        xE = xS + 0.733;
                        yS = obj.posY + 0.3;
                        yE = yS + 0.2;
                    case 'left'
                        obj.imgSrc = fliplr(obj.spriteSheet(78:93,19:45,:));
                        obj.widImg = 1.733;
                        obj.offsetX = -0.733;
                        xS = obj.posX + obj.offsetX;
                        xE = xS + 0.733;
                        yS = obj.posY + 0.3;
                        yE = yS + 0.2;
                    case 'back'
                        obj.imgSrc = obj.spriteSheet(98:125,19:34,:);
                        obj.heiImg = 1.8;
                        xS = obj.posX + 0.3;
                        xE = xS + 0.2;
                        yS = obj.posY + obj.heiPoly;
                        yE = yS + 0.8;
                    case 'front'
                        obj.imgSrc = obj.spriteSheet(48:74,19:34,:);
                        obj.heiImg = 1.733;
                        obj.offsetY = -0.733;
                        xS = obj.posX + 0.4;
                        xE = xS + 0.2;
                        yS = obj.posY + obj.offsetY;
                        yE = yS + 0.733;
                end
                obj.updateSwordPolygon(xS, xE, yS, yE);
            end

            if obj.cntAttack == 5
                switch(obj.direction)
                    case 'right'
                        obj.imgSrc = obj.spriteSheet(78:93,47:69,:);
                        obj.widImg = 1.466;
                        xS = obj.posX + obj.widPoly;
                        xE = xS + 0.466;
                        yS = obj.posY + 0.3;
                        yE = yS + 0.2;
                    case 'left'
                        obj.imgSrc = fliplr(obj.spriteSheet(78:93,47:69,:));
                        obj.widImg = 1.466;
                        obj.offsetX = -0.466;
                        xS = obj.posX + obj.offsetX;
                        xE = xS + 0.466;
                        yS = obj.posY + 0.3;
                        yE = yS + 0.2;
                    case 'back'
                        obj.imgSrc = obj.spriteSheet(99:125,36:51,:);
                        obj.heiImg = 1.733;
                        xS = obj.posX + 0.3;
                        xE = xS + 0.2;
                        yS = obj.posY + obj.heiPoly;
                        yE = yS + 0.733;
                    case 'front'
                        obj.imgSrc = obj.spriteSheet(48:70,36:51,:);
                        obj.heiImg = 1.466;
                        obj.offsetY = -0.466;
                        xS = obj.posX + 0.4;
                        xE = xS + 0.2;
                        yS = obj.posY + obj.offsetY;
                        yE = yS + 0.466;
                end
                obj.updateSwordPolygon(xS, xE, yS, yE);
            end

            if obj.cntAttack == 3
                switch(obj.direction)
                    case 'right'
                        obj.imgSrc = obj.spriteSheet(78:93,71:89,:);
                        obj.widImg = 1.2;
                        xS = obj.posX + obj.widPoly;
                        xE = xS + 0.2;
                        yS = obj.posY + 0.3;
                        yE = yS + 0.2;
                    case 'left'
                        obj.imgSrc = fliplr(obj.spriteSheet(78:93,71:89,:));
                        obj.widImg = 1.2;
                        obj.offsetX = -0.2;
                        xS = obj.posX + obj.offsetX;
                        xE = xS + 0.2;
                        yS = obj.posY + 0.3;
                        yE = yS + 0.2;
                    case 'back'
                        obj.imgSrc = obj.spriteSheet(107:125,53:68,:);
                        obj.heiImg = 1.2;
                        xS = obj.posX + 0.3;
                        xE = xS + 0.2;
                        yS = obj.posY + obj.heiPoly;
                        yE = yS + 0.2;
                    case 'front'
                        obj.imgSrc = obj.spriteSheet(48:66,53:68,:);
                        obj.heiImg = 1.2;
                        obj.offsetY = -0.2;
                        xS = obj.posX + 0.4;
                        xE = xS + 0.2;
                        yS = obj.posY + obj.offsetY;
                        yE = yS + 0.2;
                end
                obj.updateSwordPolygon(xS, xE, yS, yE);
            end

            %モーション後の初期化（cnt == 1）
            if obj.cntAttack == 1 
                switch(obj.direction)
                    case 'right'
                        obj.imgSrc = obj.spriteSheet(12:27,36:51,:);
                    case 'left'
                        obj.imgSrc = fliplr(obj.spriteSheet(12:27,36:51,:));
                    case 'back'
                        obj.imgSrc = obj.spriteSheet(12:27,70:85,:);
                    case 'front'
                        obj.imgSrc = obj.spriteSheet(12:27,2:17,:);
                end
                obj.widImg = 1;
                obj.heiImg = 1;
                obj.offsetX = 0;
                obj.offsetY = 0;
                obj.updateSwordPolygon(-2, -1, 2, 3);
            end

            %cntAttackの更新
            obj.cntAttack = max(obj.cntAttack-1, 0);

        end

        function obj = damaged(obj, hud, enemy, field)

            %Parameters
            cntInit = 30;     %カウンタの初期値
            velKnockback = 1; %ノックバック速度
            isGreen = obj.imgSrc(:,:,1) == 128 & obj.imgSrc(:,:,2) == 208 & obj.imgSrc(:,:,3) == 16; %緑色のpixelの真偽Table
            isBeige = obj.imgSrc(:,:,1) == 252 & obj.imgSrc(:,:,2) == 152 & obj.imgSrc(:,:,3) == 56; %肌色のpixelの真偽Table
            isBrown = obj.imgSrc(:,:,1) == 200 & obj.imgSrc(:,:,2) == 76 & obj.imgSrc(:,:,3) == 12;  %茶色のpixelの真偽Table

            %くらいモーション ※1フレームだけ
            if obj.cntDamaged == 0 
                %フレームカウンタの初期化
                obj.cntDamaged = cntInit;

                %HP計算&アイコン更新
                obj.curHP = max(obj.curHP-enemy.power, 0);
                hud.updateIcons(obj);

                % ノックバックベクトルの計算
                [xl, yl] = centroid(obj.polyHit.Shape);
                [xe, ye] = centroid(enemy.poly.Shape);
                vec = [xl-xe, yl-ye];
                vecUnit = vec / sqrt(vec(1)^2+vec(2)^2);
                obj.vX = velKnockback * vecUnit(1);
                obj.vY = velKnockback * vecUnit(2);

                % めり込み補正もしつつ位置更新
                obj = obj.updatePos(field.polyField);

            else 
                % くらい中のクールタイムは敵にめり込まないようにする
                % obj = obj.updatePos(obj.polyHit, enemy.poly, 0, 0);

                % ※既にMain内で一度updatePosを実行しているため、移動した後に重なった分をシフトするupdatePosではなく、
                % 別途、現時点でめり込んでいるpolygonサイズをシフト量とする処理を実施。
                polyOverlapped = intersect(obj.polyHit.Shape, enemy.poly.Shape);
                if isempty(polyOverlapped.Vertices)
                    shiftX = 0;
                    shiftY = 0;
                else
                    shiftX = max(polyOverlapped.Vertices(:,1)) - min(polyOverlapped.Vertices(:,1));
                    shiftY = max(polyOverlapped.Vertices(:,2)) - min(polyOverlapped.Vertices(:,2));
                end

                % シフト方向の決定。相対速度の符号を取らないと、どちらかが止まっているときにめり込む。
                % isShiftの意図は、自分が動いていない方向にはシフトさせたくない。例えば敵と直交したときとか。
                isShiftX = obj.vX ~= 0 || obj.vY == 0; %X方向に動いているときと静止中は1。Y方向に動いているときは0。
                isShiftY = obj.vX == 0 || obj.vY ~= 0; %Y方向に動いているときと静止中は1。X方向に動いているときは0。
                obj.posX = obj.posX - shiftX * sign( isShiftX * (obj.vX-enemy.vX) );
                obj.posY = obj.posY - shiftY * sign( isShiftY * (obj.vY-enemy.vY) );

                % ダメージエフェクト（cntごとに、普通→カラーパレット1→パレット2→パレット3→普通を繰り返す）
                % obj.imgSrcに格納すると、カラーマップの更新、alphaMapの更新、元画像のバッファが必要になり面倒だったので、
                % 元画像となるobj.imgSrcはそのままにobj.objImg.CDataを直接変更する
                switch( rem(obj.cntDamaged,4) )
                    case 0
                        obj.objImg.CData(:,:,1) = isGreen*0 + isBeige*0 + isBrown*216;
                        obj.objImg.CData(:,:,2) = isGreen*0 + isBeige*128 + isBrown*40;
                        obj.objImg.CData(:,:,3) = isGreen*0 + isBeige*136 + isBrown*0;
                    case 1
                        % cntDamaged = 0では本methodは実行されないので、静止し続けた場合を想定してcntDamaged = 1を元画像にする
                    case 2
                        obj.objImg.CData(:,:,1) = isGreen*216 + isBeige*252 + isBrown*252;
                        obj.objImg.CData(:,:,2) = isGreen*40 + isBeige*152 + isBrown*252;
                        obj.objImg.CData(:,:,3) = isGreen*0 + isBeige*56 + isBrown*252;
                    case 3
                        obj.objImg.CData(:,:,1) = isGreen*0 + isBeige*92 + isBrown*252;
                        obj.objImg.CData(:,:,2) = isGreen*0 + isBeige*148 + isBrown*252;
                        obj.objImg.CData(:,:,3) = isGreen*168 + isBeige*252 + isBrown*252;
                end

                %Imageの位置のみ更新（CDataやAlphamaを更新するとDamageエフェクトが戻ってしまう）
                xS = obj.posX + obj.offsetX;
                xE = xS + obj.widImg;
                yS = obj.posY + obj.offsetY;
                yE = yS + obj.heiImg;
                obj.objImg.XData = [xS xE];
                obj.objImg.YData = [yE yS];

                %Polygonの更新
                xS = obj.posX;
                xE = xS + obj.widPoly;
                yS = obj.posY;
                yE = yS + obj.heiPoly;
                obj.polyHit.Shape.Vertices(:,1) = [xS xS xE xE];
                obj.polyHit.Shape.Vertices(:,2) = [yS yE yE yS];
            end

            %cntDamagedの更新
            obj.cntDamaged = max(obj.cntDamaged-1, 0);

        end
    end

end