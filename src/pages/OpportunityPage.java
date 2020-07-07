/**
 * 
 */
package pages;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.FindBy;

import main.CommonActions;
import main.Utils;

/**
 * @author harvesh
 *
 */
public class OpportunityPage {

	WebDriver driver;

	public OpportunityPage(WebDriver driver) {
		this.driver = driver;
	}

	@FindBy(xpath = ".//button[@title='Edit Current Billing Relationship']")
	WebElement editBillingButton;
	@FindBy(xpath = "(//div[@class='slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click']/div/input[starts-with(@id,'input-')])[6]")
	WebElement billingDropDown;

	@FindBy(xpath = ".//lightning-base-combobox-item[@data-value='Credit Card']")
	WebElement creditCard;
	@FindBy(xpath = ".//button[@class='slds-button slds-button_brand'][@title='Save']")
	WebElement saveButton;
	@FindBy(xpath = ".//a[@title='Billing Related Ticket']")
	WebElement billingTicket;
	@FindBy(xpath = ".//a[contains(text(),'Transfer Appliance Billing')]")
	WebElement billingEmailLink;

	@FindBy(xpath = ".//button[@title='Edit Payment Profile Case #']")
	WebElement editPPC;
	@FindBy(name = "Payment_Profile_Case__c")
	WebElement fieldPPC;
	@FindBy(xpath = ".//lightning-base-combobox-item[@data-value='Invoicing']")
	WebElement invoicing;
	@FindBy(name = "Payment_Profile_ID__c")
	WebElement fieldPPID;

	@FindBy(xpath = ".//div[@class='close slds-col--bump-left slds-p-left--none slds-p-right--none ']/button") WebElement billingTab;

	
	// Actions Click
	public void opportuntiesSelection() {
		for (int i = 0; i <= 3; i++) {
			try {
				WebElement selectedOpportunties = driver
						.findElement(By.linkText(Utils.getPropertyValue("OpportunityName")));
//				CommonActions.jsClick(selectedOpportunties);
				CommonActions.jsClick(selectedOpportunties);
				break;
			} catch (Exception e) {
				System.out.println(e.getMessage());
			}
		}
	}

	public void clickBillingEdit() {
		try {
			CommonActions.jsClick(editBillingButton);
			Thread.sleep(5000);
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
		CommonActions.jsClick(billingDropDown);
	}

	public void selectCreditCard() {
		CommonActions.jsClick(creditCard);
	}

	public void saveButton() {
		CommonActions.jsClick(saveButton);
	}

	public void openBillingTicket() {
		CommonActions.jsClick(billingTicket);
	}

	public void openBillingEmailLink() {
		CommonActions.jsClick(billingEmailLink);
	}
	
	public void setProfilePaymentCase(String ppc) {		
		fieldPPC.sendKeys(ppc);
	}
	
	public void closeBillingEmailTab() {
		CommonActions.actionClick(billingTab);
	}
}