using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityStandardAssets.Characters.ThirdPerson;

public class ThirdPersonInput : MonoBehaviour
{

    public FixedJoystick LeftJoystick;
    public FixedButton Button;
    protected ThirdPersonUserControl Control;
    void Start()
    {
        Control = GetComponent<ThirdPersonUserControl>();   
    }

    // Update is called once per frame
    void Update()
    {
        Control.m_Jump = Button.Pressed;
        Control.Hinput = LeftJoystick.input.x;
        Control.Vinput = LeftJoystick.input.y;
    }
}
