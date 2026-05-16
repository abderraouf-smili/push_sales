<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

use Exception;

class StockQuantity extends Model {
    use HasFactory;
    protected $table = 'stock_quantity';
    protected $fillable = [
        'id',
        'emplacement_id',
        'is_mobile',
        'variant_id',
        'quantity',
        'previsionnel',
        'lastpurchaseprice',
        'stock_price'
    ];

    protected $hidden = [ 'created_at', 'updated_at' ];

    // static public function checkStockLevel( $variant_ids, $quantities, $emplacement_id )
    static public function checkStockLevel( $items, $warehouse_id = 0 ) {
        $outOfStock = [];
        foreach ( $items as $item ) {
            $quantity = $item[ 'quantity' ] * ( $item[ 'unite' ] == 'Cart' ?  $item[ 'package' ] : 1 );
            $stock = StockQuantity::where( 'emplacement_id', $warehouse_id != 0 ? $warehouse_id : $item[ 'warehouse_id' ] )
            ->where( 'variant_id', $item[ 'variant_id' ] )
            ->lockForUpdate()
            ->value( 'previsionnel' );
            if ( $stock < $quantity ) {
                $outOfStock[] = $item[ 'variant_id' ];
            }
        }

        return $outOfStock;
    }

    static public function checkRealStockLevel( $items, $warehouse_id ) {
        $outOfStock = [];

        foreach ( $items as $item ) {

            $stock = StockQuantity::where( 'emplacement_id', $warehouse_id )
            ->where( 'variant_id', $item[ 'variant_id' ] )
            ->lockForUpdate()
            ->value( 'quantity' );
            if ( $stock < $item[ 'quantity' ] ) {
                $outOfStock[] = $item[ 'variant_id' ];
            }
        }

        return $outOfStock;
    }

    //warehouse, variant_id, quantity
    static public function SubStockQuantity( $emplacement_id, $variant_id, $quantity ) {
        try {
            StockQuantity::where( 'emplacement_id', $emplacement_id )
            ->where( 'variant_id', $variant_id )
            ->decrement( 'quantity', $quantity );
        } catch ( Exception $e ) {
        }
    }

    //warehouse, variant_id, quantity
    static public function SubStockPrevRealQuantity( $emplacement_id, $variant_id, $quantity ) {
        try {
            $sq = StockQuantity::where( 'emplacement_id', $emplacement_id )
            ->where( 'variant_id', $variant_id )
            ->first();
            $sq->decrement( 'quantity', $quantity );
            $sq->decrement( 'previsionnel', $quantity );
            $sq->save();
        } catch ( Exception $e ) {
        }
    }

    static public function SubPrevionnelStockQuantity( $emplacement_id, $variant_id, $quantity ) {
        try {
            StockQuantity::where( 'emplacement_id', $emplacement_id )
            ->where( 'variant_id', $variant_id )
            ->decrement( 'previsionnel', $quantity );
            return 'done';
        } catch ( Exception $e ) {
            return $e->getMessage();
        }
    }

    static public function AddPrevisionnelStockQuantity( $emplacement_id, $variant_id, $quantity, $lastpp = 0, $is_mobile = false ) {
        try {
            $element = StockQuantity::where( 'emplacement_id', $emplacement_id )
            ->where( 'variant_id', $variant_id )
            ->lockForUpdate()
            ->first();
            if ( $element ) {
                $element->update( [
                    'previsionnel' => $element->previsionnel + $quantity,
                    // 'lastpurchaseprice' => $lastpp,
                    // 'stock_price' => ( $element->quantity * $element->stock_price + $quantity * $lastpp ) / ( $element->quantity + $quantity )
                ] );
            } else {
                $a = StockQuantity::create( [
                    'emplacement_id' => $emplacement_id,
                    'is_mobile' => $is_mobile,
                    'variant_id' => $variant_id,
                    'quantity' => 0,
                    'previsionnel' => $quantity,
                    'lastpurchaseprice' => $lastpp,
                    'stock_price' => $lastpp,
                ] );
            }
            return 'done';
        } catch ( Exception $e ) {
            return $e->getMessage();
        }
    }

    static public function AddRealStockQuantity( $emplacement_id, $variant_id, $quantity, $lastpp, $is_mobile = false ) {
        try {
            $element = StockQuantity::where( 'emplacement_id', $emplacement_id )
            ->where( 'variant_id', $variant_id )
            ->lockForUpdate()
            ->first();
            if ( $element ) {
                $element->update( [
                    'quantity' => $element->quantity + $quantity,
                    'previsionnel' => $element->previsionnel + $quantity,
                    'lastpurchaseprice' => $lastpp,
                    'stock_price' => ( $element->quantity * $element->stock_price + $quantity * $lastpp ) / ( $element->quantity + $quantity )
                ] );
            } else {
                $a = StockQuantity::create( [
                    'emplacement_id' => $emplacement_id,
                    'is_mobile' => $is_mobile,
                    'variant_id' => $variant_id,
                    'quantity' => $quantity,
                    'previsionnel' => $quantity,
                    'lastpurchaseprice' => $lastpp,
                    'stock_price' => $lastpp,
                ] );
            }
        } catch ( Exception $e ) {
            return $e->getMessage();
        }
    }

    static public function UpdateRealStock( $emplacement_id, $variant_id, $quantity, $addition = true, $previsionnel = false ) {
        try {
            $element = StockQuantity::where( 'emplacement_id', $emplacement_id )
            ->where( 'variant_id', $variant_id )
            ->first();
            if ( $element ) {
                if ( $addition ) {
                    $element->update( [
                        'quantity' => $element->quantity + $quantity,
                        'previsionnel' => $element->previsionnel + ( $previsionnel ? $quantity : 0 )
                    ] );
                } else {
                    $element->update( [
                        'quantity' => $element->quantity - $quantity,
                        'previsionnel' => $element->previsionnel - ( $previsionnel ? $quantity : 0 )
                    ] );
                }
            }
        } catch ( Exception $e ) {
            return $e->getMessage();
        }
    }

    static public function checkForAdjust( $warehouse_id, $items ) {
        $outOfStock = [];

        foreach ( $items as $item ) {

            $stock = StockQuantity::where( 'emplacement_id', $warehouse_id )
            ->where( 'variant_id', $item[ 'variant_id' ] )
            ->lockForUpdate()
            ->first();
            if ( $item[ 'quantity' ] + $stock->previsionnel - $stock->quantity < 0 ) {
                $outOfStock[] = $item[ 'variant_id' ];
            }
        }

        return $outOfStock;
    }

    static public function adjuster( $id, $list ) {
        foreach ( $list as $item ) {
            $stock = StockQuantity::where( 'emplacement_id', $id )->where( 'variant_id', $item[ 'variant_id' ] )->first();
            $diff = $stock->previsionnel - $stock->quantity;
            $stock->update( [ 'quantity' => $item[ 'quantity' ], 'previsionnel' => ( $item[ 'quantity' ] + $diff ) ] );
        }
    }

    public function variant() {
        return $this->hasOne( Variant::class, 'id', 'variant_id' );
    }
}
