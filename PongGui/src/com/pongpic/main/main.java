package com.pongpic.main;

import com.pongpic.model.TwoWaySerialComm;
import gnu.io.*;

public class main {

	public static void main(String[] args) {
		try
        {
            (new TwoWaySerialComm()).connect("COM3");
        }
        catch ( Exception e )
        {
        	System.out.println("NO ESTA EL PUERTO NEGRO");
            e.printStackTrace();
        }
	}
}
