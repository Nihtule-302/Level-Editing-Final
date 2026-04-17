using System;
using Unity.VisualScripting;
using UnityEditor;
using UnityEngine;

[RequireComponent(typeof(CharacterController))]
public class EnemyMovement : MonoBehaviour
{
    [Header("Movement Settings")]
    [SerializeField] private float speed = 5f;
    [Header("Object Assignment For Debugging")]
    [SerializeField] private CharacterController controller;
    [SerializeField] private Transform player;
    [Header("View Range Settings")]
    [SerializeField] private float viewRange = 10f;
    [SerializeField] private bool showViewRangeGismos = true;

    [Header("Obstacle Detection Settings")]
    [SerializeField] private LayerMask obstacleLayer;
    [SerializeField] private float obstacleCheckDistance = 1f;
    [SerializeField] private bool showRayCastGizmos = true;
    
    private bool movingRight = false;
    private Vector3 moveDirection;



    bool isActive = false;

    private void Awake()
    {
        controller = GetComponent<CharacterController>();
        player = GameObject.FindGameObjectWithTag("Player").transform;
    }
    void Update()
    {
        if (player == null) return;

        if (CheckWhenToMove())
        {
            UpdateMoveDirection();
            Move();
        }
    }

    private bool CheckWhenToMove()
    {
        bool playerWithinViewRange = Vector3.Distance(transform.position, player.position) < viewRange;
        if(!isActive && playerWithinViewRange)
        {
            isActive = true;
        }

        return playerWithinViewRange || isActive;
    }

    private void UpdateMoveDirection()
    {
        Vector3 direction = movingRight ? transform.right : -transform.right;

        if (IsObstacleAhead(direction))
        {
            movingRight = !movingRight;
            direction = movingRight ? transform.right : -transform.right;
        }

        moveDirection = direction;
    }

    private bool IsObstacleAhead(Vector3 direction)
    {
        return Physics.Raycast(transform.position, direction, obstacleCheckDistance, obstacleLayer);
    }


    private void Move()
    {
        controller.Move(speed * Time.deltaTime * moveDirection);
    }

    #if UNITY_EDITOR
    private void OnDrawGizmosSelected()
    {
        if (showViewRangeGismos)
        {
            Gizmos.color = Color.red;
            Gizmos.DrawWireSphere(transform.position, viewRange);
        }
        if (showRayCastGizmos)
        {
            Handles.color = Color.blue;
            Vector3 direction = movingRight ? transform.right : -transform.right;
            var position = transform.position + Vector3.up * 0.5f; // Raise the raycast slightly for better visibility
            Handles.DrawLine(position, position + direction * obstacleCheckDistance, 10.0f);
        }
    }
    #endif
}
