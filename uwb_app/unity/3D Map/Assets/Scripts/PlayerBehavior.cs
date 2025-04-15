using UnityEngine;
using UnityEngine.AI;

public class PlayerBehavior : MonoBehaviour
{
    private NavMeshAgent agent;
    private MqttConnection mqttConnection;
    public string deviceName;
    public string deviceId;
    [SerializeField] private GameObject rippleEffect;

    void Start()
    {
        agent = GetComponent<NavMeshAgent>();
        AttachedRipple();
    }

    public void UpdatePos(float x, float y)
    {
        Vector3 destination = new Vector3(x, 0, y);
        agent.SetDestination(destination);
    }

    private void AttachedRipple()
    {
        if (rippleEffect == null)
            return;
        GameObject rippleInstance = Instantiate(rippleEffect, transform);
        rippleInstance.transform.localPosition = Vector3.zero;
    }

}
