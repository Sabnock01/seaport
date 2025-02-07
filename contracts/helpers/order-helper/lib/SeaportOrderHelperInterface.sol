// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {
    AdvancedOrder,
    CriteriaResolver
} from "seaport-types/src/lib/ConsiderationStructs.sol";

import { CriteriaConstraint, OrderHelperResponse } from "./OrderHelperLib.sol";

interface SeaportOrderHelperInterface {
    /**
     * @notice Given an array of orders, return additional information useful
     *         for order fulfillment. This function will:
     *
     *         - Validate the orders and return associated errors and warnings.
     *         - Recommend a fulfillment method.
     *         - Suggest fulfillments.
     *         - Calculate and return `Execution` and `OrderDetails` structs.
     *         - Generate criteria resolvers based on the provided constraints.
     *
     *         "Criteria constraints" are an array of structs specifying:
     *
     *         - An order index, side (i.e. offer/consideration), and item index
     *           describing which item is associated with the constraint.
     *         - An array of eligible token IDs used to generate the criteria.
     *         - The actual token ID that will be provided at fulfillment time.
     *
     *         The order helper will calculate criteria merkle roots and proofs
     *         for each constraint, modify orders in place to add the roots as
     *         item `identifierOrCriteria`, and return the calculated proofs and
     *         criteria resolvers.
     *
     *         The order helper is designed to return details about a *single*
     *         call to Seaport. You should provide multiple orders only if you
     *         intend to call a method like fulfill available or match, *not* to
     *         batch process multiple individual calls. If you are retrieving
     *         helper data for a single order, there is a convenience function
     *         below that accepts a single order rather than an array.
     *
     *         The order helper does not yet support contract orders.
     *
     * @param orders               An array of orders to process. Only provide
     *                             multiple orders if you intend to call a
     *                             fulfill/match method.
     * @param caller               Address that will make the call to Seaport.
     * @param nativeTokensSupplied Quantity of native tokens supplied to Seaport
     *                             by the caller.
     * @param fulfillerConduitKey  Optional fulfiller conduit key.
     * @param recipient            Optional recipient address.
     * @param maximumFulfilled     Optional maximumFulfilled amount.
     * @param criteriaConstraints  An array of "criteria constraint" structs,
     *                             which describe the criteria to apply to
     *                             specific order/side/item combinations.
     *
     * @return A OrderHelperResponse struct containing data derived by the OrderHelper. See
     *         SeaportOrderHelperTypes.sol for details on the structure of this
     *         OrderHelperResponse object.
     */
    function prepare(
        AdvancedOrder[] memory orders,
        address caller,
        uint256 nativeTokensSupplied,
        bytes32 fulfillerConduitKey,
        address recipient,
        uint256 maximumFulfilled,
        CriteriaConstraint[] memory criteriaConstraints
    ) external view returns (OrderHelperResponse memory);

    /**
     * @notice Same as the above function, but accepts explicit criteria
     *         resolvers instead of criteria constraints. Skips criteria
     *         resolver generation and does not modify the provided orders. Use
     *         this if you don't want to automatically generate resolvers from
     *         token IDs.
     *
     * @param orders               An array of orders to process. Only provide
     *                             multiple orders if you intend to call a
     *                             fulfill/match method.
     * @param caller               Address that will make the call to Seaport.
     * @param nativeTokensSupplied Quantity of native tokens supplied to Seaport
     *                             by the caller.
     * @param fulfillerConduitKey  Optional fulfiller conduit key.
     * @param recipient            Optional recipient address.
     * @param maximumFulfilled     Optional maximumFulfilled amount.
     * @param criteriaResolvers    An array of explicit criteria resolvers for
     *                             the provided orders.
     *
     * @return A OrderHelperResponse struct containing data derived by the OrderHelper. See
     *         SeaportOrderHelperTypes.sol for details on the structure of this
     *         OrderHelperResponse object.
     */
    function prepare(
        AdvancedOrder[] memory orders,
        address caller,
        uint256 nativeTokensSupplied,
        bytes32 fulfillerConduitKey,
        address recipient,
        uint256 maximumFulfilled,
        CriteriaResolver[] memory criteriaResolvers
    ) external view returns (OrderHelperResponse memory);

    /**
     * @notice Convenience function for single orders.
     *
     * @param order                A single order to process.
     * @param caller               Address that will make the call to Seaport.
     * @param nativeTokensSupplied Quantity of native tokens supplied to Seaport
     *                             by the caller.
     * @param fulfillerConduitKey  Optional fulfiller conduit key.
     * @param recipient            Optional recipient address.
     * @param criteriaConstraints  An array of "criteria constraint" structs,
     *                             which describe the criteria to apply to
     *                             specific order/side/item combinations.
     *                             the provided orders.
     *
     * @return A OrderHelperResponse struct containing data derived by the OrderHelper. See
     *         SeaportOrderHelperTypes.sol for details on the structure of this
     *         OrderHelperResponse object.
     */
    function prepare(
        AdvancedOrder memory order,
        address caller,
        uint256 nativeTokensSupplied,
        bytes32 fulfillerConduitKey,
        address recipient,
        CriteriaConstraint[] memory criteriaConstraints
    ) external view returns (OrderHelperResponse memory);

    /**
     * @notice Convenience function for single orders.
     *
     * @param order                A single order to process.
     * @param caller               Address that will make the call to Seaport.
     * @param nativeTokensSupplied Quantity of native tokens supplied to Seaport
     *                             by the caller.
     * @param fulfillerConduitKey  Optional fulfiller conduit key.
     * @param recipient            Optional recipient address.
     * @param criteriaResolvers    An array of explicit criteria resolvers for
     *                             the provided orders.
     *
     * @return A OrderHelperResponse struct containing data derived by the OrderHelper. See
     *         SeaportOrderHelperTypes.sol for details on the structure of this
     *         OrderHelperResponse object.
     */
    function prepare(
        AdvancedOrder memory order,
        address caller,
        uint256 nativeTokensSupplied,
        bytes32 fulfillerConduitKey,
        address recipient,
        CriteriaResolver[] memory criteriaResolvers
    ) external view returns (OrderHelperResponse memory);

    /**
     * @notice Generate a criteria merkle root from an array of `tokenIds`. Use
     *         this helper to construct an order item's `identifierOrCriteria`.
     *
     * @param tokenIds An array of integer token IDs to be converted to a merkle
     *                 root.
     *
     * @return The bytes32 merkle root of a criteria tree containing the given
     *         token IDs.
     */
    function criteriaRoot(
        uint256[] memory tokenIds
    ) external pure returns (bytes32);

    /**
     * @notice Generate a criteria merkle proof that `id` is a member of
     *        `tokenIds`. Reverts if `id` is not a member of `tokenIds`. Use
     *         this helper to construct proof data for criteria resolvers.
     *
     * @param tokenIds An array of integer token IDs.
     * @param id       The integer token ID to generate a proof for.
     *
     * @return Merkle proof that the given token ID is  amember of the criteria
     *         tree containing the given token IDs.
     */
    function criteriaProof(
        uint256[] memory tokenIds,
        uint256 id
    ) external pure returns (bytes32[] memory);
}
