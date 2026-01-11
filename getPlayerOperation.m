function [isAttack, moveDirection] = getPlayerOperation(hid, UserData, Controller)    
    if hid.isOpen == 1
        rmsg = hid.read;
        Controller = Controller.getBtnState(rmsg);
        Controller = Controller.getJoyStickState(rmsg);

        isAttack = boolean(Controller.isPushed_A);
        moveDirection = Controller.dirLeftStick;

        if Controller.isPushed_Down == 1
            moveDirection = 'down';
        elseif Controller.isPushed_Up == 1
            moveDirection = 'up';
        elseif Controller.isPushed_Right == 1
            moveDirection = 'right';
        elseif Controller.isPushed_Left == 1
            moveDirection = 'left';
        end
    else
        switch(UserData.currentKey)
            case ''
                moveDirection = 'neutral';
            case 'w'%uparrow'
                moveDirection = 'up';
            case 'a'%leftarrow'
                moveDirection = 'left';
            case 's'%downarrow'
                moveDirection = 'down';
            case 'd'%'rightarrow'
                moveDirection = 'right';
            otherwise
                moveDirection = 'neutral';
        end
        isAttack = UserData.isClick;
    end
end