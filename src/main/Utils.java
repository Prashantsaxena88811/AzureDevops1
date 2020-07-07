package main;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.Properties;

public class Utils{

	public static long PAGE_LOAD_TIMEOUT = 50;
	public static long IMPLICIT_WAIT = 50;

	private static Properties prop;

	static {
		try {
			prop = new Properties();
			String current = System.getProperty("user.dir");
			FileInputStream ip = new FileInputStream(
					current + "//src//main//config.properties");
			prop.load(ip);
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	public static String getPropertyValue(String key) {
		return prop.getProperty(key);
	}
	
	public static void main(String args[]) throws IOException {

	}

}
