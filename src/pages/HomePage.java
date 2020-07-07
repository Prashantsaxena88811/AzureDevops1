package pages;

import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.FindBy;

import main.CommonActions;


public class HomePage{

	//Locator's
	@FindBy(css=".slds-p-horizontal__xxx-small > lightning-primitive-icon")	WebElement navigationMenu;
	@FindBy(xpath="//span[@class='slds-media__body']/span[contains(text(),'Opportunities')]")	
	WebElement opportunitiesSelection;
	
	@FindBy(xpath=".//span[contains(@class,'triggerLinkText selectedListView uiOutputText')]")	WebElement listView;
	@FindBy(xpath=".//span[@class=' virtualAutocompleteOptionText'][contains(text(),'New This Week')]")	WebElement newOpportunities;
	
	// Actions
	public void clickMenu() {
		navigationMenu.click();
	}

	public void clickOpportunities() {
		CommonActions.jsClick(opportunitiesSelection);
	}

	public void recentCreatedOpportunities() {
		listView.click();
		newOpportunities.click();
	}

}
