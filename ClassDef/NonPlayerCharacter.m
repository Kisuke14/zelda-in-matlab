classdef NonPlayerCharacter

    properties (SetAccess = private)
        posX = 8;
        posY = 6;

        heiImg = 1;
        widImg = 1;
        
        spriteSheet;
        imgSrc;
        objImg;

        heiPoly = 1;
        widPoly = 1;
        poly;

        cntStep = 0;
    end

    methods
        function obj = NonPlayerCharacter(ax)
            obj.spriteSheet = imread("Images\Miscellaneous - NPCs.png");
            obj.imgSrc = obj.spriteSheet(12:27,2:17,:);

            isColored = obj.imgSrc(:,:,1) ~= 116 & obj.imgSrc(:,:,2) ~= 116 & obj.imgSrc(:,:,3) ~= 116;
            alphaMap = ones(size(obj.imgSrc(:,:,1))) .* isColored;

            obj.objImg = image(ax, 'CData',obj.imgSrc, 'XData',[8 9], 'YData',[7 6], 'AlphaData',alphaMap);
            poly = polyshape([8 8 9 9], [6 7 7 6]);
            obj.poly = plot(ax, poly, 'LineStyle',"none", 'FaceAlpha',0);
        end

        function obj = setPosition(obj, x, y)
            %Position
            obj.posX = x;
            obj.posY = y;

            %Image
            obj.objImg.XData = [obj.posX, obj.posX+obj.widImg];
            obj.objImg.YData = [obj.posY+obj.heiImg, obj.posY];

            %Polygon
            obj.poly.Shape.Vertices(:,1) = [obj.posX, obj.posX, obj.posX+obj.widImg, obj.posX+obj.widImg];
            obj.poly.Shape.Vertices(:,2) = [obj.posY, obj.posY+obj.heiImg, obj.posY+obj.heiImg, obj.posY];
        end
    end

end