using System.Runtime.CompilerServices;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class ButtonsHandler : MonoBehaviour
{

    [SerializeField] private TMP_InputField userInputField;
    [SerializeField] private TMP_InputField mqttLogInputField;
    [SerializeField] private GameObject ipForm;
    [SerializeField] private GameObject okButton;
    [SerializeField] private GameObject cancelButton;

    private bool formStatus = false;

    private GameManager gameManager;

    private void Start()
    {
        SetFormStatus(false);
        gameManager = FindAnyObjectByType<GameManager>();
    }
    public void IPButtonPress()
    {
        SetFormStatus(formStatus = !formStatus);
    }

    public void mqttLogButtonPress()
    {
        SetMqttLogStatus();
    }
    public void OKButtonPress()
    {
        string inputText = userInputField.text;
        if (gameManager != null)
        {
            gameManager.UpdateIPAddress(inputText);
        }
        SetFormStatus (formStatus = false);
    }
    public void CancelButtonPress()
    {
        SetFormStatus(formStatus = false);
    }

    private void SetFormStatus(bool status)
    {
        ipForm.SetActive(status);
        okButton.SetActive(status);
        cancelButton.SetActive(status);
    }
    private void SetMqttLogStatus()
    {
        bool currentStatus = mqttLogInputField.gameObject.activeSelf;
        mqttLogInputField.gameObject.SetActive(!currentStatus);
    }
}
