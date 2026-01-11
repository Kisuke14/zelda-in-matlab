
%%%%% MATLABで初代ゼルダの再現

clear
close
clc

%%%%% Initialization

%%% Parameters
fps = 30;
isDebug = 0;        %Parameter for Joy-Con
vendorID = 0x57E;   %Parameter for Joy-Con (Nintendo Co., Ltd)
productID = 0x2009; %Parameter for Joy-Con (0x2006: Joy-Con L / 0x2007: Joy-Con R / 0x2009: Switch Pro Controller)
nReadBuffer = 64;   %Parameter for Joy-Con
nWriteBuffer = 64;  %Parameter for Joy-Con

%%% UI-Figure
ui = UI;
hud = HUD(ui.mapPanel, ui.hudPanel);
field = Field(ui.fieldPanel);

%%% Characters
% Link
Link = PlayerCharacter(field.ax);
Link.updateObjImgPolygon;
hud.updateIcons(Link);

% Enemies
Octarock = Enemy(field.ax);
Octarock.updateObjImgPolygon;

% NPCs
oldMan = NonPlayerCharacter(field.ax);

%%% HID-API (ProController)
% Object
hid = hidapi(isDebug, vendorID, productID, nReadBuffer, nWriteBuffer);
str = hid.enumerate(vendorID, productID);
controller = JoyController;

% Connection
if ~isempty(str.Value.serial_number) %isConnected
    hid.open
    hid.sendSubCommand(3, 0x30, 1); %操作情報を60Hzで送信させるコマンド ※6軸IMUセンサの有効化はsendSubCommand(0x40,1,1)、無効化はsendSubCommand(0x40,0,1)
    pause(0.1);
end

%% 
%%%%% Main Loop

tic % Timer start

while(isgraphics(ui.fig))

    %%% Initialize
    [isAttack, moveDirection] = getPlayerOperation(hid, ui.fig.UserData, controller);

    elapsedTime = toc;
    if elapsedTime > 1/fps
        %%% Action
        % Link
        if isAttack || Link.cntAttack > 0
            Link = Link.attackByClick();
            ui.fig.UserData.isClick = false;
        else
            Link = Link.moveByKey(moveDirection, fps);
            Link = Link.updatePos(field.polyField);
        end
        Link.updateObjImgPolygon; % imgとpolyの位置更新

        % Enemy
        if Octarock.cntSpawned > 0
            Octarock = Octarock.spawn(Octarock.posX, Octarock.posY);
        end
        if Octarock.spawned
            Octarock = Octarock.move(field, fps, Link);
            Octarock.updateObjImgPolygon; % imgとpolyの位置更新
        end

        %%% Interaction
        % Attack
        arrayOverlaps = overlaps([Link.swordPoly.Shape, Octarock.poly.Shape]);
        if arrayOverlaps(2,1) || Octarock.cntDamaged > 0
            Octarock = Octarock.vanish;
        end

        % Damaged
        arrayOverlaps = overlaps([Link.polyHit.Shape, Octarock.poly.Shape]);
        if arrayOverlaps(2,1) || Link.cntDamaged > 0
            Link = Link.damaged(hud, Octarock, field);
        end

        % Area Change
        [field, Link] = field.entryCave(Link);
        [field, Link] = field.exitCave(Link);
        [field, hud, Link, Octarock] = field.changedArea(hud, Link, Octarock);

        tic % Timer reset
    end

    %%% update Graphic
    drawnow limitrate

end

%%%%% Break
if hid.isOpen == 1
    hid.close
end