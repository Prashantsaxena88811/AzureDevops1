package TestCases;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;

public class UseCase1 {

	public static void main(String[] args) {
		// TODO` Auto-generated method stub
	//	System.setProperty("webdriver.chrome.driver","C:\\\\chromedriver.exe");
		WebDriver driver = new ChromeDriver();
		driver.get("https://login.salesforce.com/");
		driver.findElement(By.xpath("//input[@class='input r4 wide mb16 mt8 username']")).sendKeys("Prashantsxntesting8@gmail.com");
		driver.findElement(By.xpath("//input[@class='input r4 wide mb16 mt8 password']")).sendKeys("Prashant@123");
		driver.findElement(By.xpath("//input[@class='button r4 wide primary']")).click();

	}

}
