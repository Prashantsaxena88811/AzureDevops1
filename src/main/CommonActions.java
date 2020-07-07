package main;

import java.util.List;
import java.util.Set;

import org.openqa.selenium.By;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.interactions.Actions;
import org.openqa.selenium.support.ui.WebDriverWait;

public class CommonActions extends TestBase {

	public static  void clearOpenTabs() {
		List<WebElement> allTabs = driver.findElements(
				By.cssSelector(".slds-button.slds-button_icon.slds-button_icon-x-small.slds-button_icon-container"));
//		System.out.println("Total Tabs : " + allTabs.size());
		if (allTabs.size() > 0) {
			for (WebElement tabClsoeButton : allTabs) {
				WebDriverWait wait = new WebDriverWait(driver,10);
				tabClsoeButton.click();
				System.out.println("Tab Closed");
			}
		} else {
			System.out.println("No Opportunities Tab's Found ");
		}
	}

	public static void swtichNextWindow() {
		String parentWindow = driver.getWindowHandle();
//		System.out.println("P" + parentWindow);
		Set<String> allWindow = driver.getWindowHandles();
//		System.out.println("A" + allWindow);
		for (String childWindow : allWindow) {
			if (!childWindow.equals(parentWindow)) {
				driver.switchTo().window(childWindow);
			} 
		}
}

	public static void swtichMainWindow() {
		String parentWindow = driver.getWindowHandle();
//		System.out.println("P" + parentWindow);
		Set<String> allWindow = driver.getWindowHandles();
//		System.out.println("A" + allWindow);
		for (String childWindow : allWindow) {
			if (!childWindow.equals(parentWindow)) {
				
				driver.close();
				driver.switchTo().window(childWindow);
			} 
		}
	}

	// Test Comment

	public static void actionClick(WebElement element) {
		Actions actionClick = new Actions(driver);
		actionClick.moveToElement(element).click(element).perform();
	}

	public static void jsClick(WebElement element) {
		JavascriptExecutor jsClick = (JavascriptExecutor) driver;
		jsClick.executeScript("arguments[0].click();", element);
	}
}
