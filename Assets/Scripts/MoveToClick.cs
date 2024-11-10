using UnityEngine;

public class MoveToClick : MonoBehaviour
{
    [SerializeField] private float movementSpeed;
    [SerializeField] private MousePosition2D mousePosition2D;
    private Vector3 targetPosition;

    void Start()
    {
        transform.position = targetPosition;
    }

    void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            targetPosition = mousePosition2D.mouseWorldPosition;
            
        }
        MoveToTarget();
        RotateToTarget();
        
    }

    private void MoveToTarget()
    {
        transform.position = Vector3.MoveTowards(transform.position, targetPosition, Time.deltaTime * movementSpeed);
    }

    private void RotateToTarget()
    {
        var diff = targetPosition - transform.position;
        transform.right = diff;
    }
}
